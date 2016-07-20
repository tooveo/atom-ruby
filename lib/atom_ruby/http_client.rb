require 'net/http'
require 'uri'
module IronSourceAtom
  ResponseMock = Struct.new(:code, :message, :body)
  class HttpClient

    # Sends http post to atom url with data in body
    # * +threads_max_num+ url of ironSourceAtom host
    # * +data+ body of http post request
    def post(url, data)
      uri = URI(url)
      initheader = {'Content-Type' => 'application/json',
                    'x-ironsource-atom-sdk-type' => 'atom-ruby',
                    'x-ironsource-atom-sdk-version' => IronSourceAtom::VERSION}
      req = Net::HTTP::Post.new(uri.path, initheader)
      req.body = data
      response = Net::HTTP.new(uri.host, uri.port).start { |http| http.request(req) }
      return response
    rescue Errno::ECONNRESET, Errno::ECONNREFUSED
      ResponseMock.new(400, 'connection error', "No internet connection")
    end
  end
end


