require 'net/http'
require 'celluloid'

module IronSourceAtom
  class HttpClient
    include Celluloid

    def initialize(url, data, callback)
      @url = url
      @data = data
      @callback = callback

      @init_header = {'Content-Type' => 'application/json',
                      'x-ironsource-atom-sdk-type' => 'atom-ruby',
                      'x-ironsource-atom-sdk-version' => IronSourceAtom::VERSION}
    end

    # Sends http post to atom url with data in body
    # * +threads_max_num+ url of ironSourceAtom host
    # * +data+ body of http post request
    def post
      _request :post
    end

    def get
      _request :get
    end

    def _request(method)
      if @callback
        async._async_callback method
      else
        return _internal_request(method)
      end
    end

    def _async_callback(method)
      @callback.call(_internal_request(method))
    end

    def _internal_request(method)
      begin
        uri = URI.parse(@url)
        http = Net::HTTP.new(uri.host, uri.port)
        request = nil

        case method
          when :post
            request = Net::HTTP::Post.new(uri.request_uri, @init_header)
            request.body = @data
          when :get
            uri_with_data = uri.request_uri + '?data=' + Utils.urlsafe_encode64(@data)

            puts uri_with_data
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


