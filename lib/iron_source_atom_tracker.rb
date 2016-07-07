require 'thread'
require 'iron_source_atom'
require 'json'
class IronSourceAtomTracker

  Event = Struct.new(:stream, :data)
  BULK_BYTES_SIZE = 1024
  BULK_SIZE = 3

  # Creates a new instance of IronSourceAtomTracker.
  # * +auth+ is the pre shared auth key for your Atom. Required.
  # * +url+ atom traker endpoint url.
  def initialize(url="http://track.atom-data.io/")
    @url =url
    @auth=""
    @streams = Hash.new
    @atom = IronSourceAtom.new
    @flush_now = false
    @worker_runing = true
    @event_worker_thread=Thread.start{event_worker}

  end

  def finalize
    @worker_runing = false
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
    events_size = Hash.new
    events_buffer = Hash.new
    flush_event = lambda do |stream, auth, buffer|
      buffer_to_flush = Array.new(buffer).to_json
      buffer.clear;
      events_size[stream] = 0;
      flush_data(stream, buffer_to_flush);
    end

    while true
      for stream in @streams.keys
        value = @streams[stream].pop
        if value==nil
          Thread.sleep(1)
          next
        end

        if !events_size.key? stream
          events_size.store(stream, 0)
        end

        if !events_buffer.key? stream
          events_buffer.store(stream, Array.new)
        end

        events_size[stream] += value[:data].bytesize
        events_buffer[stream].push value[:data]

         if events_size[stream] >= BULK_BYTES_SIZE
          flush_event.call(stream, @auth, events_buffer[stream])
         end

        if events_buffer[stream].length >= BULK_SIZE
          flush_event.call(stream, @auth, events_buffer[stream])
        end

        if @flush_now
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
    @atom.put_events(stream, data)
  end


  def flush
    @flush_now = true
  end


end