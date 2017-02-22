require 'thread'
require 'json'
require '../lib/iron_source_atom'

class TestTracker
def self.test_multitrhead
  url = "http://track.atom-data.io/"

  # Example of error callback
  # error_callback = lambda do |error_str, stream, data|
  #   print "Error Callback: #{error_str}; stream: #{stream}\n"
  # end

  atom_tracker = IronSourceAtom::Tracker.new(url, nil, is_blocking=true)
  atom_tracker.auth = "YOUR AUTH KEY"
  atom_tracker.is_debug_mode = true
  atom_tracker.backlog_size = 100
  atom_tracker.bulk_length=10000000
  atom_tracker.bulk_size_byte=513*1024
  atom_tracker.flush_interval=5

  stream = 'YOUR STREAM NAME'

  # Track events
  for index in 0..100
    puts "Put event: #{index}"
    data = {
      id: index,
      strings: "data index: #{index}"
    }.to_json
    atom_tracker.track(stream, data)
    sleep(0.01)
  end
  atom_tracker.flush

  # # Track strings
  data_string = {
      id: 1,
      message: "11"
  }.to_json

  atom_tracker.track(stream, data_string)
  atom_tracker.track(stream, data_string)
  atom_tracker.track(stream, data_string)
  atom_tracker.track(stream, data_string)

  atom_tracker.flush_with_stream(stream)

  index = 10
  i = 0
  index_exit = 0
  while index_exit < 100
    sleep(0.2)

    i += 1
    index_exit += 1
    print "index: #{index_exit}\n"
    if i >= index
      i = 0
      atom_tracker.track(stream, data_string)
      atom_tracker.flush_with_stream(stream)
    end
  end

  atom_tracker.finalize
end

test_multitrhead

end
