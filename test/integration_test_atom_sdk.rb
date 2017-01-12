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

  		event_count = ARGV[0]

  		puts "From test: #{event_count}"

			atom_tracker.auth = "I40iwPPOsG3dfWX30labriCg9HqMfL"

			stream = 'sdkdev_sdkdev.public.g8y3etest'

			for index in 0..event_count.to_i
				#puts "Put event: #{index}"
				data = {
						id: index,
						strings: "data index: #{index}"
				}.to_json
				atom_tracker.track(stream, data)
				sleep(0.03)
			end

			atom_tracker.flush(lambda do |response|
				puts "Test ran successfully!\n Response code: #{response.code}\n Response message #{response.message}"
			end)

			sleep(10)
  	end

	do_test_job

end

