require 'json'
require_relative 'atom'
require_relative 'back_off'
require_relative 'atom_debug_logger'

require 'thread'

require 'timers'

module IronSourceAtom
  class Tracker
    include Celluloid

    @@tracker_lock = Mutex.new

    attr_reader :is_debug_mode
    attr_reader :bulk_size_byte
    attr_reader :bulk_size
    attr_reader :backlog_size
    attr_reader :flush_interval

    @@FLUSH_INTERVAL = 10
    @@BULK_SIZE = 50
    @@BULK_SIZE_LIMIT = 2000
    @@BULK_SIZE_BYTE = 128 * 1024
    @@BULK_SIZE_BYTE_LIMIT = 512 * 1024

    # Creates a new instance of Atom Tracker.
    # * +url+ atom tracker endpoint url. Default is http://track.atom-data.io/
    def initialize(url = 'http://track.atom-data.io/')
      @is_debug_mode = false

      @bulk_size_byte = @@BULK_SIZE_BYTE
      @backlog_size = 500
      @bulk_size = @@BULK_SIZE
      @flush_interval = @@FLUSH_INTERVAL

      @retry_timeout = 1

      @url = url
      @atom = Atom.new

      @accumulate = Hash.new

      @queue_flush = Hash.new
      @is_stream_flush = Hash.new

      @timerRetry = Timers::Group.new

      async._timer_flush
    end

    def finalize
      self.terminate
    end

    # Sets pre shared auth key for Atom Stream
    # * +auth+ Pre shared auth key for your Atom Stream
    def auth=(auth)
      @atom.auth = auth
    end

    # Sets bulk size byte for Atom Tracker events
    # * +size_byte+ bulk size in bytes
    def bulk_size_byte=(size_byte)
      if size_byte < 1 or size_byte > @@BULK_SIZE_BYTE_LIMIT
        AtomDebugLogger.log('Maximum Bulk byte size is reached (default: 128kB)', @is_debug_mode)
        @bulk_size_byte = @@BULK_SIZE_BYTE
      else
        @bulk_size_byte = size_byte
      end
    end

    # Sets bulk size for Atom Tracker events
    # * +size+ bulk size
    def bulk_size=(size)
      if size < 1 or size > @@BULK_SIZE_LIMIT
        AtomDebugLogger.log('Bulk Length is reached (default: 50 events).', @is_debug_mode)
        @bulk_size = @@BULK_SIZE
      else
        @bulk_size = size
      end
    end

    # Sets flush interval Atom Tracker events
    # * +flush_interval+ flush interval in seconds
    def flush_interval=(flush_interval)
      if flush_interval < 0.001
        AtomDebugLogger.log('Flush Interval is reached (default: 10 seconds).', @is_debug_mode)
        @flush_interval = @@FLUSH_INTERVAL
      else
        @flush_interval = flush_interval
      end
    end

    # Sets url for Atom Tracker
    # * +url+ url for Atom server
    def url=(url)
      @atom.url = url
    end

    # Sets debug mode for Atom Tracker
    # * +is_debug_mode+ enable debug mode
    def is_debug_mode=(is_debug_mode)
      @is_debug_mode = is_debug_mode
      @atom.is_debug_mode = is_debug_mode
    end

    # Track data to Atom
    # * +stream+ Atom Stream name
    # * +data+ Data to be sent
    # * +error_callback+ Called after max retires failed or after client-side error
    def track(stream, data, error_callback = nil)

      @@tracker_lock.lock
      if (stream.nil? || stream.length == 0 || data.nil? || data.length == 0)
        raise StandardError, 'Stream name and data are required parameters'
      end

      unless @accumulate.key?(stream)
        @accumulate[stream] = []
      end

      if @accumulate[stream].length >= @backlog_size
        error_str = "Message store for stream: '#{stream}' has reached its maximum size!"
        AtomDebugLogger.log(error_str, @is_debug_mode)
        error_callback.call(error_str, @accumulate[stream]) unless error_callback.nil?
        @@tracker_lock.unlock
        return
      end

      unless data.is_a?(String)
        if data.method_defined? :to_json
          @accumulate[stream].push(data.to_json)
        else
          raise StandardError, "Invalid Data - can't be stringified"
        end
      else
        @accumulate[stream].push(data)
      end
      @@tracker_lock.unlock

      #AtomDebugLogger.log("Track event for stream: #{stream} with data: #{data}", @is_debug_mode)

      if @accumulate[stream].length >= @bulk_size || _byte_count(@accumulate[stream]) >= @bulk_size_byte
        flush_with_stream(stream)
      end
    end

    # Flush all Streams to Atom
    # * +callback+ called with results
    def flush(callback = nil)
      @accumulate.each do |stream, data|
        flush_with_stream(stream, callback)
      end
    end

    # Flush a specific Stream to Atom
    # * +stream+   Atom Stream name
    # * +callback+ called with results
    def flush_with_stream(stream, callback = nil)
      @@tracker_lock.lock
      if @is_stream_flush[stream]
        @queue_flush[stream] = true
        @@tracker_lock.unlock
        return
      end

      @is_stream_flush[stream] = true
      if @accumulate[stream].length > 0
        data = @accumulate[stream]
        @accumulate[stream] = []
      else
        @@tracker_lock.unlock
        return
      end
      @@tracker_lock.unlock

      AtomDebugLogger.log("Flush event for stream: #{stream}", @is_debug_mode)

      _send(stream, data, @retry_timeout, callback) if data != nil && data.length > 0
    end

    def _timer_flush
      every(flush_interval) do
        AtomDebugLogger.log("From flush timer! interval: #{flush_interval}\n", @is_debug_mode)
        flush
      end
    end


    # Internal function that uses the "low level sdk" to send data (put_events func)
    # * +stream+   Atom Stream name
    # * +data+   Data to be sent
    # * +timeout+   Max retry time
    # * +timeout+   callback that will be called when done/error.
    def _send(stream, data, timeout, callback)
      @atom.put_events(stream, data, 'post', nil, lambda do |response|
        if response.code.to_i <= -1 || response.code.to_i >= 500
          print "from timer: #{timeout}\n"
          if timeout < 20 * 60
            @timerRetry.after(timeout) {
              timeout = timeout * 2 + (rand(1000) + 100) / 1000.0

              _send(stream, data, timeout, callback)
            }

            @timerRetry.wait
            return
          else
            callback.call(Net::HTTPResponse.new(nil, 408, 'Timeout - No response from server')) unless callback.nil?
          end
        end

        # retry queue mechanism
        @is_stream_flush[stream] = false
        if @queue_flush[stream]
          @queue_flush[stream] = false
          flush
        end

        AtomDebugLogger.log("Flush response code: #{response.code}\n response message #{response.message}", @is_debug_mode)

        callback.call(response) unless callback.nil?
      end)
    end

    def _byte_count(data_array)
      result_size = 0
      for data in data_array
        result_size += data.bytesize
      end

      return result_size
    end
  end
end
