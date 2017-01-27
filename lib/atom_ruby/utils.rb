require 'openssl'
require "base64"

module IronSourceAtom
  class Utils
    def self.auth(key, data)
      digest = OpenSSL::Digest.new('sha256')

      OpenSSL::HMAC.hexdigest(digest, key, data)
    end

    def self.urlsafe_encode64(data)
      Base64.urlsafe_encode64(data)
    end
  end
end