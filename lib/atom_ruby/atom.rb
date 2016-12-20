require_relative 'utils'
require_relative 'http_client'
require 'json'

module IronSourceAtom
  class Atom
    attr_accessor :auth
    attr_accessor :url

    # Creates a new instance of Atom.
    # * +auth+ is the pre shared auth key for your Atom.
    # * +url+ atom tracker endpoint url.
    def initialize(auth = '', url= 'http://track.atom-data.io/')
      raise ArgumentError.new("Param 'auth' must not be nil!") if auth == nil

      @url = url
      @auth = auth
    end

    def _get_event_data(stream, data, auth, is_bulk = false)

      unless data.is_a?(String)
        if data.is_a?(Array) && data[0].is_a?(String)
          data = data.join(',')
          data = '[' + data + ']'
        elsif data.respond_to? :to_json
          data = data.to_json
        else
          raise StandardError, "Invalid Data - can't be stringified"
        end
      end

      event = {
          table: stream,
          data: data,
          bulk: is_bulk,
          auth: Utils.auth(auth, data)
      }.to_json
    end

    # writes a single data event into ironSource.atom delivery stream.
    # to write multiple data records into a delivery stream, use put_events.
    #
    # * +stream+ the name of your Atom stream.
    # * +data+ your data in JSON format.
    # * +auth+ is the pre shared auth key for your Atom. Required. By default uses authKey set in Atom constructor
    #
    # returns an HTTPResponse object.
    #
    def put_event(stream, data, auth = '', callback = nil)
      auth = @auth if auth == nil || auth.empty?
      raise ArgumentError.new("Param 'stream' must be neither nil nor empty!") if stream == nil || stream.empty?

      event = _get_event_data(stream, data, auth, false)

      http_client = HttpClient.new(@url, event, callback)
      http_client.post
    end

    # writes a multiple data events into ironSource.atom delivery stream.
    # to write  single data event into a delivery stream, use put_event.
    #
    # * +stream+ the name of your Atom stream.
    # * +data+ your data in JSON format.
    # * +auth+ is the pre shared auth key for your Atom. Required. By default uses authKey set in Atom constructor
    #
    # returns an HTTPResponse object.
    #
    def put_events(stream, data, auth = '', callback = nil)
      auth = @auth if auth == nil || auth.empty?
      raise ArgumentError.new("Param 'stream' must be neither nil nor empty!") if stream == nil || stream.empty?

      event = _get_event_data(stream, data, auth, true)

      http_client = HttpClient.new(@url, event, callback)
      http_client.post
    end
  end
end