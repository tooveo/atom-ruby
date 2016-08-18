require 'celluloid/current'
require 'json'
require_relative 'atom'
require_relative 'back_off'
require_relative 'event_task_worker'
require_relative 'atom_debug_logger'
module IronSourceAtom
  class Tracker
    include Celluloid
    Event = Struct.new(:stream, :data)

    # Creates a new instance of Tracker.
    # * +url+ atom traker endpoint url. Default is http://track.atom-data.io/
    def initialize(url="http://track.atom-data.io/")
      @bulk_size_byte = 64*1024
      @bulk_size = 4
      @task_pool_size = 10000
      @flush_interval = 10
      @task_workers_count = 10
      @event_queue = Queue.new
      @url = url
      @streams = Hash.new
      @streams_data = Hash.new
      @atom = Atom.new
      @flush_now = false
      async.event_worker
      task_pool = EventTaskWorker.pool(size: @task_workers_count)
      task_pool.work_task(@event_queue)

    end

    # Sets pre shared auth key for Atom stream
    # * +auth+ String pre shared auth key
    def is_debug_mode=(id_debug_mode)
      @is_debug_mode = id_debug_mode
    end

    # Sets pre shared auth key for Atom stream
    # * +auth+ String pre shared auth key
    def auth=(auth)
      @atom.auth = auth
    end

    # Sets bulk size of events in bytes
    def bulk_size_byte=(bulk_size_byte)
      @bulk_size_byte = bulk_size_byte
    end

    # Sets number of events in bulk
    def bulk_size=(bulk_size)
      @bulk_size = bulk_size
    end


    # Sets the capacity of task queue
    def task_pool_size=(task_pool_size)
      @task_pool_size = task_pool_size
    end

    # Sets the time in seconds for flushing data to Atom
    def flush_interval=(flush_interval)
      @flush_interval = flush_interval
    end


    # Track data to server
    #
    # * +data+ info for sending
    # * +stream+ is the Name of the stream
    # * +auth+ is the pre shared auth key for your Atom. Required. By default uses authKey set to Tracker instance
    def track(data, stream, auth = '')

      if auth==nil || auth.empty?
        auth = @atom.auth
      end

      unless @streams_data.has_key? stream
        @streams_data.store(stream, auth)
      end

      if @streams.has_key? stream
        @streams[stream].push Event.new(stream, data)
      else
        events_queue = Queue.new
        events_queue.push Event.new(stream, data)
        @streams.store(stream, events_queue)
      end

    end

    private def event_worker

      timer_start_time = Hash.new
      timer_delta_time = Hash.new
      events_size = Hash.new
      events_buffer = Hash.new

      flush_event = lambda do |stream, auth, buffer|
        buffer_to_flush = Array.new(buffer).to_json
        buffer.clear
        events_size[stream] = 0
        timer_delta_time[stream] = 0
        add_task(Proc.new { flush_data(stream, buffer_to_flush, auth) })
      end

      every (0.01) do
        for stream in @streams_data.keys

          unless timer_start_time.key? stream
            timer_start_time.store(stream, Time.now)
          end

          unless timer_delta_time.key? stream
            timer_delta_time.store(stream, 0)
          end

          timer_delta_time[stream] += Time.now - timer_start_time[stream]
          timer_start_time[stream] = Time.now

          if timer_delta_time[stream] >= @flush_interval
            timer_delta_time[stream] = 0

            if events_buffer[stream].length > 0
              AtomDebugLogger.log("flushing event by timer #{events_buffer[stream]}", @is_debug_mode)
              flush_event.call(stream, @streams_data[stream], events_buffer[stream])
            end

          end


          begin
            value = @streams[stream].pop(true)
          rescue Exception => e
            sleep 0.1
            next
          end

          unless events_size.key? stream
            events_size.store(stream, 0)
          end

          unless events_buffer.key? stream
            events_buffer.store(stream, Array.new)
          end

          events_size[stream] += value[:data].bytesize
          events_buffer[stream].push value[:data]

          if events_size[stream] >= @bulk_size_byte
            AtomDebugLogger.log("Flushing event by exceeding  bulk_size_byte #{events_buffer[stream]}", @is_debug_mode)
            flush_event.call(stream, @streams_data[stream], events_buffer[stream])
          end

          if events_buffer[stream].length >= @bulk_size
            AtomDebugLogger.log("Flushing event by exceeding bulk_size #{events_buffer[stream]}", @is_debug_mode)
            flush_event.call(stream, @streams_data[stream], events_buffer[stream])
          end

          if @flush_now
            AtomDebugLogger.log("Flushing event by client demand #{events_buffer[stream]}", @is_debug_mode)
            flush_event.call(stream, @streams_data[stream], events_buffer[stream])
          end

        end

        if @flush_now
          @flush_now = false
        end
      end

    end


    private def flush_data(stream, data, auth)
      back_off=BackOff.new
      while true
        sleep 0.01
        AtomDebugLogger.log("Request data: #{data}"+"\n", @is_debug_mode)
        response=@atom.put_events(stream, data, auth)
        AtomDebugLogger.log("Responce code from server is: #{response.code}"+"\n", @is_debug_mode)

        if Integer(response.code) < 500
          return
        end
        sleep back_off.retry_time
      end
    end

    # Flush all data buffer to server immediately
    def flush
      @flush_now = true
    end

    # Adds task into task queue. Raises RuntimeError if @event_queue length reaches its maximum
    private def add_task(task)
      if @event_queue.length > @task_pool_size
        raise "Events task queue is reached maximum length"
      end
      @event_queue.push task
    end
  end
end
