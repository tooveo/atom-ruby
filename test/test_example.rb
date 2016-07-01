require "test/unit"
require 'json'
require 'iron_source_atom'
class TestExample < Test::Unit::TestCase

  def self.do_test_job
    url = "http://track.atom-data.io/"
    auth = "I40iwPPOsG3dfWX30labriCg9HqMfL"
    atom = IronSourceAtom.new(auth)
    data_string ={
        id: 1,
        message: "hello_from_ruby"
    }.to_json
    response = atom.put_event("sdkdev_sdkdev.public.atomtestkeyone", data_string)
    puts "Response #{response.code} #{response.message}:
          #{response.body}"

    data1={
        id: 11,
        message: "first_array_data"
    }
    data2={
        id: 12,
        message: "second_array_data"
    }
    data3={
        id: 13,
        message: "third_array_data"
    }
    array_data_string=[data1, data2, data3].to_json

    response =  atom.put_events("sdkdev_sdkdev.public.atomtestkeyone", array_data_string)
    puts "Response #{response.code} #{response.message}:
          #{response.body}"

  end
    do_test_job

end