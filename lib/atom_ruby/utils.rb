require 'openssl'
class Utils
    def self.auth(key, data)
      digest = OpenSSL::Digest.new('sha256')
      return OpenSSL::HMAC.hexdigest(digest,key, data)
    end
end