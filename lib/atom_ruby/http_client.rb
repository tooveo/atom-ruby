require 'net/http'
require 'json'
require 'uri'
class HttpClient

  def post(url, data)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = data
    response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
    puts "Request #{req.body}"
    return response

  end

end


