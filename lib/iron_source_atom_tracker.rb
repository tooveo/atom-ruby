require 'thread'
require 'iron_source_atom'
require 'json'
require 'atom_ruby/back_off'
require 'atom_ruby/event_task_pool'
class IronSourceAtomTracker

  Event = Struct.new(:stream, :data)
  BULK_BYTES_SIZE = 1024
  BULK_SIZE = 3
  TASK_WORKERS_COUNT = 20
  TASK_POOL_SIZE = 10000
  FLUSH_INTERVAL = 20

  # Creates a new instance of IronSourceAtomTracker.
  # * +auth+ is the pre shared auth key for your Atom. Required.
  # * +url+ atom traker endpoint url.
  def initialize(url="http://track.atom-data.io/")
    @url =url
    @auth=""
    @streams = Hash.new
    @atom = IronSourceAtom.new
    @flush_now = false
    @worker_running = true
    @event_worker_thread=Thread.start{event_worker}
    @event_pool = EventTaskPool.new(TASK_WORKERS_COUNT, TASK_POOL_SIZE)

  end

  def finalize
    @worker_running = false
    @event_worker_thread.join 100
    puts "I am finalizing"
  end

  def auth=(auth)
    @auth=auth
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

  def event_worker
    timer_start_time = Time.now
    timer_delta_time = 0
    events_size = Hash.new
    events_buffer = Hash.new
    flush_event = lambda do |stream, auth, buffer|
        buffer_to_flush = Array.new(buffer).to_json
        buffer.clear
        events_size[stream] = 0
        timer_delta_time = 0;
        @event_pool.add_task(Proc.new {flush_data(stream, buffer_to_flush)})
      end

    while true
      for stream in @streams.keys
        timer_delta_time += Time.now - timer_start_time
        timer_start_time = Time.now
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
        puts "Data pushed to the buffer #{value[:data]}"

         if events_size[stream] >= BULK_BYTES_SIZE
          flush_event.call(stream, @auth, events_buffer[stream])
         end

        if events_buffer[stream].length >= BULK_SIZE
          flush_event.call(stream, @auth, events_buffer[stream])
        end

        if @flush_now
          flush_event.call(stream, @auth, events_buffer[stream])
        end


        if timer_delta_time >= FLUSH_INTERVAL
            timer_delta_time = 0
        Puts "Timer"
            flush_event.call(stream, @auth, events_buffer[stream])
        end

      end

      if @flush_now
        @flush_now = false
      end
    end

  end

  def flush_data(stream, data)
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


  def flush
    @flush_now = true
  end


end