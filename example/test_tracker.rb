require 'thread'
require 'json'
require '../lib/iron_source_atom'

class TestTracker
def self.test_multitread
  url = "http://track.atom-data.io/"
  atom_tracker = IronSourceAtom::Tracker.new
  atom_tracker.auth = ""
  atom_tracker.is_debug_mode = true

  data_string = {
      id: 1,
      message: "11"
  }.to_json

  error_callback = lambda do |error_str|
    print "Error: #{error_str}\n"
  end

  stream = 'sdkdev_sdkdev.public.g8y3etest'
  atom_tracker.track(stream, data_string, error_callback)
  atom_tracker.track(stream, data_string, error_callback)
  atom_tracker.track(stream, data_string, error_callback)
  atom_tracker.track(stream, data_string, error_callback)

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

  atom_tracker.flush_with_stream(stream, reponse_callback)

  print "ssssswwww\n"
  index = 10
  i = 0
  indexExit = 0
  while indexExit < 100
    print "11111\n"
    sleep(0.2)
    print "3333\n"

    i += 1
    indexExit += 1
    print "index: #{indexExit}\n"
    if i >= index
      i = 0
      atom_tracker.track(stream, data_string, error_callback)
      atom_tracker.flush_with_stream(stream, reponse_callback)
    end
  end

  atom_tracker.finalize
end

test_multitread

end
