require 'net/http'
require 'uri'
class HttpClient

  def post(url, data)
    uri = URI(url)
    initheader = {'Content-Type' =>'application/json',
                  'x-ironsource-atom-sdk-type' => 'atom-ruby',
                  'x-ironsource-atom-sdk-version' => IronSourceAtom::VERSION}
    req = Net::HTTP::Post.new(uri.path, initheader)
    req.body = data
    response = Net::HTTP.new(uri.host, uri.port).start {|http| http.request(req) }
    puts "Request #{req.body}"
    return response

  end

end


