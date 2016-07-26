require 'thread'
require 'json'
require_relative 'atom'
require_relative 'back_off'
require_relative 'event_task_pool'
module IronSourceAtom
  class Tracker
    Event = Struct.new(:stream, :data)

    # Creates a new instance of Tracker.
    # * +auth+ is the pre shared auth key for your Atom. Required.
    # * +url+ atom traker endpoint url.
    def initialize(url="http://track.atom-data.io/")
      @bulk_size_byte = 64*1024
      @bulk_size = 4
      @task_workers_count = 20
      @task_pool_size = 10000
      @flush_interval = 10
      @url =url
      @auth=""
      @streams = Hash.new
      @atom = Atom.new
      @flush_now = false
      @event_worker_thread=Thread.start { event_worker }
      @event_pool = EventTaskPool.new(@task_workers_count, @task_pool_size)

    end

    # Sets pre shared auth key for Atom stream
    # * +auth+ String pre shared auth key
    def auth=(auth)
      @auth = auth
    end

    # Sets bulk size of events in bytes
    def bulk_size_byte=(bulk_size_byte)
      @bulk_size_byte = bulk_size_byte
    end

    # Sets number of events in bulk
    def bulk_size=(bulk_size)
      @bulk_size = bulk_size
    end

    # Sets the quantity of workers sending data to Atom
    def task_workers_count=(task_workers_count)
      @task_workers_count = task_workers_count
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
    def track(data, stream)
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

      flush_event = lambda do |stream, buffer|
        buffer_to_flush = Array.new(buffer).to_json
        buffer.clear
        events_size[stream] = 0
        timer_delta_time[stream] = 0;
        @event_pool.add_task(Proc.new { flush_data(stream, buffer_to_flush) })
      end

      while true
        for stream in @streams.keys

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
              puts "flushing event by timer #{events_buffer[stream]}"
              flush_event.call(stream, events_buffer[stream])
            end

          end

          value = @streams[stream].pop
          if value==nil
            sleep(0.1)
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
            flush_event.call(stream, events_buffer[stream])
          end

          if events_buffer[stream].length >= @bulk_size
            flush_event.call(stream, events_buffer[stream])
          end

          if @flush_now
            flush_event.call(stream, events_buffer[stream])
          end

        end

        if @flush_now
          @flush_now = false
        end
      end

    end


    private def flush_data(stream, data)
      @atom.auth = @auth
      back_off=BackOff.new
      while true
        response=@atom.put_events(stream, data)
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
  end

end