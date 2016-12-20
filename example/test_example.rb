require 'json'
require '../lib/iron_source_atom'

class TestExample
  def self.do_test_job
    url = "http://track.atom-data.io/"
    auth = ""
    atom = IronSourceAtom::Atom.new(auth)

    atom.url = url

    data_string = {
        id: 1,
        message: "hello_from_ruby"
    }.to_json

    reponse_callback = lambda do |response|
      begin
        print "Reponse code: #{response.code}\n"
        print "Reponse message: #{response.message}\n"

        print "Response body: #{response.body}\n"
      rescue Exception => ex
        print ex.message
      end
    end

    atom.put_event("sdkdev_sdkdev.public.g8y3etest2", data_string, "I40iwPPOsG3dfWX30labriCg9HqMfL", reponse_callback)

    puts "ni11;"
  end

  do_test_job

end