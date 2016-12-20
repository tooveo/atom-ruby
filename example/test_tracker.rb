require 'thread'
require 'json'
require '../lib/iron_source_atom'

class TestTracker
def self.test_multitread
  url = "http://track.atom-data.io/"
  atom_tracker = IronSourceAtom::Tracker.new
  atom_tracker.auth = ""

  data_string = {
      id: 1,
      message: "11"
  }.to_json

  stream = 'sdkdev_sdkdev.public.g8y3etest'
  atom_tracker.track(stream, data_string)

  print "adssdsads\n"

  reponse_callback = lambda do |response|
    begin
      print "Reponse code: #{response.code}\n"
      print "Reponse message: #{response.message}\n"

      print "Response body: #{response.body}\n"
    rescue Exception => ex
      print ex.message
    end
  end

  atom_tracker.flush(stream, reponse_callback)

  print "ssssswwww\n"
  index = 10
  i = 0
  while true
    print "11111\n"
    sleep(0.2)
    print "3333\n"

    i += 1
    if i >= index
      i = 0
      atom_tracker.flush(stream, reponse_callback)
    end

  end
end

test_multitread

end
