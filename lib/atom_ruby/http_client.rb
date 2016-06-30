require 'net/http'
require 'json'
require 'uri'
class HttpClient

  def post(url, data)
    uri = URI(url)
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.body = data
    response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
    puts req.body
    puts "Response #{response.code} #{response.message}:
          #{response.body}"

  end

end


