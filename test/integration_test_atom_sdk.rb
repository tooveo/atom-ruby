require 'json'
require 'iron_source_atom'
require 'thread'

puts "Integration test for ruby atom sdk!\n\n"

class AtomApiThread
  @@stopped = false

  def initialize(atom_tracker=nil, stream=nil, queue=nil, invalid_queue=nil, keep_alive_sec=0, stall_seconds=0, type='tracker')
    raise TypeError, ('expected Thread::Queue') unless queue.instance_of? Thread::Queue
    @atom_tracker = atom_tracker
    @stream = stream
    @queue = queue
    @invalid_queue = invalid_queue
    @keep_alive_sec = keep_alive_sec
    @stall_seconds = stall_seconds
    @type = type
  end
  def self.stop
    @@stopped = true
  end

  def thread_worker(id)
    begin
      original_timer = @keep_alive_sec
      while not @@stopped do
        #printf "From Thread\n"
        if @queue.length <= 0
          sleep(1)
        else
          queue_item = @queue.pop
          begin
            # puts queue_item.to_json
            if @type == :tracker
              @atom_tracker.track(@stream, queue_item.to_json)
              #puts "Track: #{@stream} data: #{queue_item}\n"

            end
          rescue => e
            puts "track failed: \n"
            puts e.backtrace
            @invalid_queue << queue_item.to_json
          end
          if @stall_seconds != 0
            sleep(@stall_seconds)
          end
        end
      end
    rescue => e
      puts "something wrong in thread #{id}: #{e.message}"
    end
  end
end

class IntegrationTest
  	def self.do_test
  		# get arguments
  		stream = ARGV[0]
  		auth = ARGV[1]
  		event_count = ARGV[2]
  		bulk_length = ARGV[3]
  		bulk_size_byte = ARGV[4]

  		send_data_types = ARGV[5]
  		data_key_increment = ARGV[6]

  		flush_interval = ARGV[7]

      queue = Queue.new
      invalid_queue = Queue.new

  		puts "Args - stream: #{stream}; auth: #{auth}; even_count: #{event_count}; bulk_length: #{bulk_length}; \n bulk_size_byte: #{bulk_size_byte}; send_data_types: #{send_data_types}; data_key_increment: #{data_key_increment}"

  		data_types = JSON.parse(send_data_types)

	    atom_tracker = IronSourceAtom::Tracker.new
  		atom_tracker.auth = auth
  		atom_tracker.bulk_length = bulk_length.to_i
  		atom_tracker.bulk_size_byte = bulk_size_byte.to_i
  		atom_tracker.is_debug_mode = true
  		atom_tracker.flush_interval = flush_interval.to_i

  		puts "From test: #{event_count}"

			event_per_sec = 0
      prev_time = Time.now

      prev_data = {}
      prev_data[data_key_increment] = 0

      thread_array = Array.new
      IntegrationTest.build_threads(thread_array, atom_tracker, stream, queue, invalid_queue, 3, 5, 0.01)

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

        #atom_tracker.track(stream, data.to_json)
        queue << data
        sleep(0.001)

        event_per_sec += 1
        if Time.now - prev_time >= 1
          prev_time = Time.now
          print "\n------------------------\nEvents per second: #{event_per_sec}\n------------------------\n"
          event_per_sec = 0
        end
      end

      puts "End Testing.\n"

      while queue.length > 0
        sleep(0.5)
      end

      puts "Queue empty.\n"

      AtomApiThread.stop

      atom_tracker.flush(lambda do |response|
        puts "Test ran successfully!\n Response code: #{response.code}\n Response message #{response.message}"
      end)

      sleep(10)
    end

    def self.build_threads(thread_array, atom_tracker, stream, queue, invalid_queue, threads=1, keep_alive_time=10, thread_stall_time=0)
      threads.times do |i|
        print "Build thread #{i}\n"
        thread = AtomApiThread.new(atom_tracker, stream, queue, invalid_queue, keep_alive_time, thread_stall_time, type=:tracker)
        thread_array << Thread.new{thread.thread_worker(i)}
      end
      puts "built #{thread_array.length} threads"
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

