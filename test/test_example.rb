require "test/unit"
require 'iron_source_atom'
class TestExample < Test::Unit::TestCase

  def self.do_test_job
    url = "http://track.atom-data.io/"
    auth = "I40iwPPOsG3dfWX30labriCg9HqMfL"
    atom = IronSourceAtom.new(url, auth)
    data ={
        "id" => 1,
        "message" => "hello_from_ruby"
    };
    atom.put_event("sdkdev_sdkdev.public.atomtestkeyone", data)

    data1={
        "id" => 2,
        "message" => "first_array_data"
    }
    data2={
        "id" => 3,
        "message" => "second_array_data"
    }
    data3={
        "id" => 4,
        "message" => "third_array_data"
    }
    arraydata=[data1, data2, data3]

    atom.put_events("sdkdev_sdkdev.public.atomtestkeyone", arraydata)

  end
    do_test_job
end