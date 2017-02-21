require 'thread'
require 'json'
require '../lib/iron_source_atom'

class TestTracker
def self.test_multitread
  url = "http://track.atom-data.io/"

  error_callback = lambda do |error_str, stream, data|
    print "Error: #{error_str}; stream: #{stream}\n"
  end

  atom_tracker = IronSourceAtom::Tracker.new(url, error_callback, is_blocking=false)
  atom_tracker.auth = "YOUR AUTH KEY"
  atom_tracker.is_debug_mode = true
  atom_tracker.backlog_size = 100

  stream = 'YOUR STREAM NAME'

  for index in 0..1400
    puts "Put event: #{index}"
    data = {
      id: index,
      strings: "data index: #{index}"
    }.to_json
    atom_tracker.track(stream, data)
    sleep(0.01)
  end

  atom_tracker.flush(lambda do |response|
    puts "Test ran successfully!\n Response code: #{response.code}\n Response message #{response.message}"
  end)

  data_string = {
      id: 1,
      message: "11"
  }.to_json

  atom_tracker.track(stream, data_string)
  atom_tracker.track(stream, data_string)
  atom_tracker.track(stream, data_string)
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

  atom_tracker.flush_with_stream(stream, reponse_callback)

  index = 10
  i = 0
  indexExit = 0
  while indexExit < 100
    sleep(0.2)

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
