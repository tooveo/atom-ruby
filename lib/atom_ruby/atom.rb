require_relative 'utils'
require_relative 'http_client'
module IronSourceAtom
  class Atom
    # Creates a new instance of IronSourceAtom.
    # * +auth+ is the pre shared auth key for your Atom. Required.
    # * +url+ atom traker endpoint url.
    def initialize(auth="", url="http://track.atom-data.io/")
      if auth==nil
        raise ArgumentError.new("Param 'auth' must not be nil!")
      end
      @url =url
      @auth=auth
    end

    # :nocov:
    def auth=(auth)
      @auth=auth
    end

    # :nocov:

    # writes a single data event into ironSource.atom delivery stream.
    # to write multiple data records into a delivery stream, use put_events.
    #
    # * +stream+ the name of your Atom stream.
    # * +data+ your data in JSON format.
    #
    # returns an HTTPResponse object.
    #
    def put_event(stream, data)
      if stream==nil || stream.empty?
        raise ArgumentError.new("Param 'stream' must be neither nil nor empty!")
      end
      event ={
          table: stream,
          data: data,
          bulk: false,
          auth: Utils.auth(@auth, data)
      }.to_json;
      http_client=HttpClient.new
      return http_client.post(@url, event)
    end

    # writes a multiple data events into ironSource.atom delivery stream.
    # to write  single data event into a delivery stream, use put_event.
    #
    # * +stream+ the name of your Atom stream.
    # * +data+ your data in JSON format.
    #
    # returns an HTTPResponse object.
    #
    def put_events(stream, data)
      if stream==nil || stream.empty?
        raise ArgumentError.new("Param 'stream' must be neither nil nor empty!")
      end
      event ={
          table: stream,
          data: data,
          bulk: true,
          auth: Utils.auth(@auth, data)
      }.to_json;
      http_client=HttpClient.new
      response = http_client.post(@url, event)
      puts "Response #{response.code} #{response.message}:
        #{response.body}"

      return response
    end
  end
end