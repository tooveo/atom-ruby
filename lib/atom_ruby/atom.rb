require_relative 'utils'
require_relative 'http_client'
require_relative 'atom_debug_logger'

require 'json'

module IronSourceAtom
  class Atom
    attr_accessor :auth
    attr_accessor :url
    attr_accessor :is_debug_mode

    # Creates a new instance of Atom Base SDK.
    # * +auth+ Pre shared auth key for your Atom Stream
    # * +url+ Atom API endpoint url. Default is http://track.atom-data.io/
    def initialize(auth = '', url= 'http://track.atom-data.io/')
      raise ArgumentError.new("Param 'auth' must be not nil!") if auth == nil

      @is_debug_mode = false

      @url = url
      @auth = auth
    end

    def _get_event_data(stream, data, auth, is_bulk = false)
      if data == nil
        raise ArgumentError.new("Param 'data' must be not nil!")
      end

      if data.is_a?(String)
        if data == ''
          raise ArgumentError.new("Param 'data' must be not empty!")
        end
      else
        # :nocov:
        if data.is_a?(Array) && data[0].is_a?(String)
          data = data.join(',')
          data = '[' + data + ']'
        elsif data.respond_to? :to_json
          data = data.to_json
        else
          raise StandardError, "Invalid Data - can't be stringified"
        end
        # :nocov:
      end

      # :nocov:
      event = {
          table: stream,
          data: data,
          bulk: is_bulk,
          auth: Utils.auth(auth, data)
      }.to_json
      # :nocov:
    end

    # Send a single data event into ironSource.atom
    # * +stream+ Atom Stream name
    # * +data+ Data in JSON format.
    # * +auth+ Pre shared auth key for your Stream, by default uses authKey set in Atom constructor
    #
    # returns an HTTPResponse object.
    #
    def put_event(stream, data, auth = '', callback = nil)
      auth = @auth if auth == nil || auth.empty?
      raise ArgumentError.new("Param 'stream' must be neither nil nor empty!") if stream == nil || stream.empty?

      event = _get_event_data(stream, data, auth, false)
      # :nocov:
      AtomDebugLogger.log("Put event with stream: #{stream} data: #{event}", @is_debug_mode)

      http_client = HttpClient.new(@url, event, callback)
      http_client.post
      # :nocov:
    end

    # Send multiple events (bulk/batch) to Atom API
    #
    # * +stream+ Atom Stream name
    # * +data+ your data in JSON format.
    # * +auth+ Pre shared auth key for your Stream, by default uses authKey set in Atom constructor
    #
    # returns an HTTPResponse object.
    #
    def put_events(stream, data, auth = '', callback = nil)
      auth = @auth if auth == nil || auth.empty?
      raise ArgumentError.new("Param 'stream' must be neither nil nor empty!") if stream == nil || stream.empty?

      event = _get_event_data(stream, data, auth, true)
#     :nocov:
      AtomDebugLogger.log("Put events with stream: #{stream} data: #{event}", @is_debug_mode)

      http_client = HttpClient.new(@url, event, callback)
      http_client.post
      # :nocov:
    end
  end
end