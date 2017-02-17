require 'net/http'
require 'celluloid'
require "celluloid/current"
require "celluloid/extras/rehasher"
require 'celluloid/pool'

module IronSourceAtom
  class HttpClient
    include Celluloid

    def initialize
      @init_header = {'Content-Type' => 'application/json',
                      'x-ironsource-atom-sdk-type' => 'atom-ruby',
                      'x-ironsource-atom-sdk-version' => IronSourceAtom::VERSION}
    end

    # Sends HTTP POST to Atom API
    def post(url, data, callback)
      _request :post, url, data, callback
    end

    def get(url, data, callback)
      _request :get, url, data, callback
    end

    def _request(method, url, data, callback)
      if callback
        callback.call(_internal_request(method, url, data))
      else
        return _internal_request(method, url, data)
      end
    end

    def _internal_request(method, url, data)
      begin
        uri = URI.parse(url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = nil

        case method
          when :post
            request = Net::HTTP::Post.new(uri.request_uri, @init_header)
            request.body = data
          when :get
            uri_with_data = uri.request_uri + '?data=' + Utils.urlsafe_encode64(data)
            request = Net::HTTP::Get.new(uri_with_data, @init_header)
        end

        return http.request(request)
      rescue Exception => ex
        if ex.instance_variable_defined?(:@response)
          return ex.response
        else
          return Net::HTTPResponse.new(nil, -1, ex.message)
        end
      end
    end
  end
end


