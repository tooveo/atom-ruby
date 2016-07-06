require 'thread'
require 'iron_source_atom'
class IronSourceAtomTracker

  # Creates a new instance of IronSourceAtomTracker.
  # * +auth+ is the pre shared auth key for your Atom. Required.
  # * +url+ atom traker endpoint url.
  def initialize(url="http://track.atom-data.io/")
    if auth==nil
      raise ArgumentError.new("Param 'auth' must not be nil!")
    end
    @url =url
    @auth=""
    @streams = Hash.new
    @atom = IronSourceAtom.new(@auth)

  end

  def auth=(auth)
    @auth=auth
  end


  # Track data to server
  #
  # * +data+ info for sending
  # * +stream+ is the Name of the stream
  def track(data, stream, auth=@auth)
    if @streams.has_key? stream
      @streams[stream].push data
    else
      events_queue = Queue.new
      events_queue.push data
      @streams.store(stream, events_queue)

    end
  end

  def event_worker
    
  end

  def flush_data(stream, data)
    @atom.put_events(stream, data)
  end


  def flush

  end

end