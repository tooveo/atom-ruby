require 'json'
require 'iron_source_atom'

puts "Integration test for ruby atom sdk!\n\n"

class IntegrationTest
  	def self.do_test
  		# get arguments
  		stream = ARGV[0]
  		auth = ARGV[1]
  		event_count = ARGV[2]
  		bulk_size = ARGV[3]
  		bulk_size_byte = ARGV[4]

  		send_data_types = ARGV[5]
  		data_key_increment = ARGV[6]

  		flush_interval = ARGV[7]

  		puts "Args - stream: #{stream}; auth: #{auth}; even_count: #{event_count}; bulk_size: #{bulk_size}; \n bulk_size_byte: #{bulk_size_byte}; send_data_types: #{send_data_types}; data_key_increment: #{data_key_increment}"

  		data_types = JSON.parse(send_data_types)

	    atom_tracker = IronSourceAtom::Tracker.new
  		atom_tracker.auth = auth
  		atom_tracker.bulk_size = bulk_size.to_i
  		atom_tracker.bulk_size_byte = bulk_size_byte.to_i
  		atom_tracker.is_debug_mode = true
  		atom_tracker.flush_interval = flush_interval.to_i

  		puts "From test: #{event_count}"

		  stream = 'sdkdev_sdkdev.public.g8y3etest'

      event_per_sec = 0
      prev_time = Time.now

      prev_data = {}
      prev_data[data_key_increment] = 0

      for index in 0..event_count.to_i
        #puts "Put event: #{index}"
        data = {}

        data_types.each do |key, value|
          is_inc = data_key_increment == key
          data_value = nil
          if is_inc
            prev_data[data_key_increment] =  IntegrationTest.generate_data(value, is_inc, prev_data[data_key_increment])
            data_value = prev_data[data_key_increment]
          else
            data_value = IntegrationTest.generate_data(value)
          end
          data[key] = data_value
        end

        atom_tracker.track(stream, data.to_json)
        sleep(0.005)

        event_per_sec += 1
        if Time.now - prev_time >= 1
          prev_time = Time.now
          print "\n------------------------\nEvents per second: #{event_per_sec}\n------------------------\n"
          event_per_sec = 0
        end
      end

      atom_tracker.flush(lambda do |response|
        puts "Test ran successfully!\n Response code: #{response.code}\n Response message #{response.message}"
      end)

      sleep(10)
    end

  	def self.generate_data(type, is_autoincrement = false, prev_value = nil)
      case type
        when "int"
          if is_autoincrement
            return prev_value + 1
          else
            return Random.rand(1000)
          end
        when "str"
          return (0...(20 + Random.rand(100))).map { ('a'..'z').to_a[rand(26)] }.join
        when "bool"
          return Random.rand(1) == 1
        end
  	end

	do_test
end

