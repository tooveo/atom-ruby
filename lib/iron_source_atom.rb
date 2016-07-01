require "atom_ruby/version"
require "atom_ruby/http_client"
require "atom_ruby/utils"

class IronSourceAtom
  def initialize(url, auth)
    @url =url
    @auth=auth
  end

  def put_event(stream, data)
    event ={
        "table" => stream,
        "data" => data.to_json,
        "bulk" => false,
        "auth" => Utils.auth(@auth, data.to_json)
    }.to_json;
    http_client=HttpClient.new
    http_client.post(@url, event)

  end

  def put_events(stream, data)
    event ={
        "table" => stream,
        "data" => data.to_json,
        "bulk" => true,
        "auth" => Utils.auth(@auth, data.to_json)
    }.to_json;
    http_client=HttpClient.new
    http_client.post(@url, event)

  end

end
