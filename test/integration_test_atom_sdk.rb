require 'json'
require 'iron_source_atom'

puts "Integration test for ruby atom sdk!\n\n"

class TestExample
  	def self.do_test_job
  		url = 'http://track.atom-data.io/'
	    auth = ''
	    stream = 'ibtest'

	    atom_tracker = IronSourceAtom::Tracker.new
  		atom_tracker.auth = auth
  		atom_tracker.is_debug_mode = true

		data = {
			id: 1,
			message: 'test 42'
		}.to_json
		atom_tracker.track(stream, data)

		atom_tracker.flush(lambda do |response|
			puts "Test runned successfully!\n Reponse code: #{response.code}\n Response message #{response.message}"
		end)
  	end

	do_test_job

end

