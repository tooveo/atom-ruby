require "atom_ruby/version"
require "atom_ruby/http_client"

class IronSourceAtom
  def initialize(url, auth)
    @url =url
    @auth=auth
  end

  def put_event(stream, data)
    event ={
        "table" => stream,
        "data" => data,
        "bulk" => false
    }.to_json;
    http_client=HttpClient.new
    http_client.post(@url, event)

  end

  def put_events(stream, data)
    event ={
        "table" => stream,
        "data" => data,
        "bulk" => true
    }.to_json;
    http_client=HttpClient.new
    http_client.post(@url, event)

  end

end
