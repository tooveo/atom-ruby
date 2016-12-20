require 'json'
require '../lib/iron_source_atom'

class TestExample
  def self.do_test_job
    url = "http://track.atom-data.io/"
    auth = ""
    atom = IronSourceAtom::Atom.new(auth)

    atom.url = url
    atom.is_debug_mode = true

    stream = 'ibtest'
    auth_key = '<YOUR_AUTH_KEY>'

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

    puts 'Put event test'
    atom.put_event(stream, data_string, auth_key, reponse_callback)


    data_string_json = {
        id: 2,
        message: 'hello_from_ruby_2'
    }

    puts 'Put event with json object test'
    atom.put_event(stream, data_string_json, auth_key, reponse_callback)

    data_str_array_json = [
        {
            id: 1,
            msg: 'test 1'
        },
        {
            id: 2,
            msg: 'test 2'
        }
    ].to_json

    puts 'Put events with string'
    atom.put_events(stream, data_str_array_json, auth_key, reponse_callback)

    data_array_with_str_json = [
        "{\"id\": 1, \"msg\": \"test 1\"}",
        "{\"id\": 2, \"msg\": \"test 2\"}",
    ]

    puts 'Put events with json object'
    atom.put_events(stream, data_array_with_str_json, auth_key, reponse_callback)

    data_array_json = [
        {
            id: 1,
            msg: 'test 1'
        },
        {
            id: 2,
            msg: 'test 2'
        }
    ]

    puts 'Put events with json object'
    atom.put_events(stream, data_array_json, auth_key, reponse_callback)

    puts "From test"
  end

  do_test_job

end