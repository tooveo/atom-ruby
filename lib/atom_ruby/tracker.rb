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
    attr_accessor :bulk_size_byte
    attr_accessor :bulk_size
    attr_accessor :task_pool_size
    attr_accessor :flush_interval

    # Creates a new instance of Tracker.
    # * +url+ atom tracker endpoint url. Default is http://track.atom-data.io/
    def initialize(url = 'http://track.atom-data.io/')
      @is_debug_mode = false

      @bulk_size_byte = 64 * 1024
      @bulk_size = 4
      @task_pool_size = 2
      @flush_interval = 10
      @task_workers_count = 10

      @retry_timeout = 1

      @url = url
      @atom = Atom.new

      @accumulate = Hash.new

      @queue_flush = Hash.new
      @is_stream_flush = Hash.new

      @timerRetry = Timers::Group.new

      async._timer_flush
    end

    def finalize()
      self.terminate
    end

    # Sets pre shared auth key for Atom stream
    # * +auth+ String pre shared auth key
    def auth=(auth)
      @atom.auth = auth
    end

    def url=(url)
      @atom.url = url
    end

    def is_debug_mode=(is_debug_mode)
      @is_debug_mode = is_debug_mode
      @atom
    end

    def track(stream, data, error_callback = nil)
      @@tracker_lock.lock
      if (stream.nil? || stream.length == 0 || data.nil? || data.length == 0)
        raise StandardError, 'Stream name and data are required parameters'
      end

      unless @accumulate.key?(stream)
        @accumulate[stream] = []
      end

      if @accumulate[stream].length >= @task_pool_size
        error_str = "Message store for stream: '#{stream}' has reached its maximum size!";
        AtomDebugLogger.log(error_str, @is_debug_mode)
        error_callback.call(error_str) unless error_callback.nil?
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

      AtomDebugLogger.log("Track event for stream: #{stream} with data: #{data}", @is_debug_mode)

      if @accumulate[stream].length >= @bulk_size || _byte_count(@accumulate[stream]) >= @bulk_size_byte
        flush(stream)
      end
    end

    def flush(callback = nil)
      @accumulate.each do |stream, data|
        flush_with_stream(stream, callback)
      end
    end

    def flush_with_stream(stream, callback = nil)
      @@tracker_lock.lock
      if @accumulate[stream].length > 0
        data = @accumulate[stream]
        @accumulate[stream] = []
      else
        @@tracker_lock.unlock
        return
      end

      if @is_stream_flush[stream]
        @queue_flush[stream] = true
        @@tracker_lock.unlock
        return
      end

      @is_stream_flush[stream] = true
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
