require "atom_ruby/version"
require "atom_ruby/http_client"
require "atom_ruby/utils"

# This class is the entry point into this client API
class IronSourceAtom


  # Creates a new instance of IronSourceAtom.
  # * +auth+ is the pre shared auth key for your Atom. Required.
  # * +url+ atom traker endpoint url.
  def initialize(auth, url="http://track.atom-data.io/")
    @url =url
    @auth=auth
  end

  # writes a single data event into ironSource.atom delivery stream.
  # to write multiple data records into a delivery stream, use put_events.
  #
  # * +stream+ the name of your Atom stream.
  # * +data+ your data in JSON format.
  #
  # returns an HTTPResponse object.
  #
  def put_event(stream, data)
    event ={
        table: stream,
        data: data,
        bulk: false,
        auth: Utils.auth(@auth, data.to_json)
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
    event ={
        table: stream,
        data: data,
        bulk: true,
        auth: Utils.auth(@auth, data.to_json)
    }.to_json;
    http_client=HttpClient.new
    return http_client.post(@url, event)
  end

end
