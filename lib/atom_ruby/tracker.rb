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
    @@tracker_block_lock = Mutex.new

    attr_reader :is_debug_mode
    attr_reader :bulk_size_byte
    attr_reader :bulk_length
    attr_reader :backlog_size
    attr_reader :flush_interval

    @@FLUSH_INTERVAL = 10
    @@BULK_LENGTH = 50
    @@BULK_LENGTH_LIMIT = 2000
    @@BULK_SIZE_BYTE = 128 * 1024
    @@BULK_SIZE_BYTE_LIMIT = 512 * 1024

    # Creates a new instance of Atom Tracker.
    # * +url+ Atom tracker endpoint url. Default is http://track.atom-data.io/
    # * +error_callback+ Optional, callback to be called when there is an error at the tracker
    # * +is_blocking+ Optional, should the tracker block, default true.
    def initialize(url = 'http://track.atom-data.io/', error_callback = nil, is_blocking = true)
      @is_debug_mode = false

      @bulk_size_byte = @@BULK_SIZE_BYTE
      @backlog_size = 2000
      @bulk_length = @@BULK_LENGTH
      @flush_interval = @@FLUSH_INTERVAL

      @retry_timeout = 1

      @url = url
      @atom = Atom.new

      @accumulate = Hash.new

      @queue_flush = Hash.new
      @is_stream_flush = Hash.new

      # Default error callback func
      default_error_callback = lambda do |error_str, stream, data|
        print "Error Callback: #{error_str}; stream: #{stream}\n"
      end
      @error_callback = error_callback.nil? ? default_error_callback : error_callback

      @timerRetry = Timers::Group.new
      @is_blocking = is_blocking

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

    # Set Batch(Bulk) size byte for Atom Tracker events
    # * +byte_size+ bulk size in bytes
    def bulk_size_byte=(byte_size)
      if byte_size < 1 or byte_size > @@BULK_SIZE_BYTE_LIMIT
        AtomDebugLogger.log("Invalid Bulk Size, must be between 1 to #{@@BULK_SIZE_BYTE_LIMIT} setting to default: #{@@BULK_SIZE_BYTE})", @is_debug_mode)
        @bulk_size_byte = @@BULK_SIZE_BYTE
      else
        @bulk_size_byte = byte_size
      end
    end

    # Sets bulk length for Atom Tracker events
    # * +bulk_length+ bulk length
    def bulk_length=(bulk_length)
      if bulk_length < 1 or bulk_length > @@BULK_LENGTH_LIMIT
        AtomDebugLogger.log("Invalid Bulk Length, must be between 1 to #{@@BULK_LENGTH_LIMIT} setting to default: #{@@BULK_LENGTH}", @is_debug_mode)
        @bulk_length = @@BULK_LENGTH
      else
        @bulk_length = bulk_length
      end
    end


    # Sets backlog size for Atom Tracker
    # * +backlog_size+ backlog size
    def backlog_size=(backlog_size)
      @backlog_size = backlog_size
    end

    # Sets flush interval Atom Tracker events
    # * +flush_interval+ flush interval in seconds
    def flush_interval=(flush_interval)
      if flush_interval < 0.001
        AtomDebugLogger.log("Invalid FlushInterval, must be bigger than 100 ms, setting it to #{@@FLUSH_INTERVAL} seconds", @is_debug_mode)
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
    def track(stream, data)
      @@tracker_lock.lock
      if (stream.nil? || stream.length == 0 || data.nil? || data.length == 0)
        raise StandardError, 'Stream name and data are required parameters'
      end

      unless @accumulate.key?(stream)
        @accumulate[stream] = []
      end

      if @accumulate[stream].length >= @backlog_size
        if @is_blocking 
          @@tracker_lock.unlock
          while (@accumulate[stream].length >= @backlog_size)
            sleep(0.5)
            flush_with_stream(stream)
          end

          @@tracker_lock.lock
        else
          error_str = "Message store for stream: '#{stream}' has reached its maximum size!"
          AtomDebugLogger.log(error_str, @is_debug_mode)
          @error_callback.call(error_str, stream, @accumulate[stream])
          @accumulate[stream] = []
          @@tracker_lock.unlock

          return
        end
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
      @@tracker_lock.unlock if @@tracker_lock.locked?

      #AtomDebugLogger.log("Track event for stream: #{stream} with data: #{data}", @is_debug_mode)

      if @accumulate[stream].length >= @bulk_length || _byte_count(@accumulate[stream]) >= @bulk_size_byte
        flush_with_stream(stream)
      end
    end

    # Flush all Streams to Atom
    def flush
      @accumulate.each do |stream, data|
        flush_with_stream(stream)
      end
    end

    # Flush a specific Stream to Atom
    # * +stream+   Atom Stream name
    def flush_with_stream(stream)
      @@tracker_lock.lock
      if @is_stream_flush[stream]
        @queue_flush[stream] = true
        @@tracker_lock.unlock
        return
      end

      @is_stream_flush[stream] = true
      if @accumulate[stream].length > 0

        if @accumulate[stream].length > @bulk_length
          data = @accumulate[stream].take(@bulk_length)
          @accumulate[stream] = @accumulate[stream].drop(@bulk_length)
          @queue_flush[stream] = true
        else
          data = @accumulate[stream]
          @accumulate[stream] = []
        end
      else
        @@tracker_lock.unlock
        return
      end
      @@tracker_lock.unlock

      AtomDebugLogger.log("Flush event for stream: #{stream}", @is_debug_mode)

      _send(stream, data, @retry_timeout) if data != nil && data.length > 0
    end

    def _timer_flush
      every(flush_interval) do
        AtomDebugLogger.log("Flush Interval of: #{flush_interval} reached\n", @is_debug_mode)
        flush
      end
    end

    # Internal function that uses the "low level sdk" to send data (put_events func)
    # * +stream+   Atom Stream name
    # * +data+   Data to be sent
    # * +timeout+   Max retry time
    def _send(stream, data, timeout)
      @atom.put_events(stream, data, 'post', nil, lambda do |response|
        if response.code.to_i <= -1 || response.code.to_i >= 500
          print "from timer: #{timeout}\n"
          if timeout < 20 * 60
            @timerRetry.after(timeout) {
              timeout = timeout * 2 + (rand(1000) + 100) / 1000.0

              _send(stream, data, timeout)
            }

            @timerRetry.wait
            return
          else
            error_str = 'Timeout - No response from server'
            AtomDebugLogger.log(error_str, @is_debug_mode)
            @error_callback.call(error_str, stream, data)
            return
          end
        end

        # retry queue mechanism
        @is_stream_flush[stream] = false
        if @queue_flush[stream]
          @queue_flush[stream] = false
          flush
        end

        if response.code.to_i != 200
            error_str = response.message
            AtomDebugLogger.log(error_str, @is_debug_mode)
            @error_callback.call(error_str, stream, data)
        end

        AtomDebugLogger.log("Flush response code: #{response.code} - response message #{response.message}", @is_debug_mode)
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
