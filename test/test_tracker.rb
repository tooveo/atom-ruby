require 'thread'
require 'json'
require 'iron_source_atom_tracker'
require_relative 'helper'
class TestTracker
  def self.do_test_job
    url = "http://track.atom-data.io/"
    atom_tracker = IronSourceAtomTracker.new
    atom_tracker.auth="I40iwPPOsG3dfWX30labriCg9HqMfL"

    data1={
        id: 11,
        message: "first_array_data"
    }.to_json
    data2={
        id: 12,
        message: "second_array_data"
    }.to_json
    data3={
        id: 13,
        message: "third_array_data"
    }.to_json

    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    sleep(1)
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data2, "sdkdev_sdkdev.public.atomtestkeyone")
    sleep(4)
    atom_tracker.track(data2, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data3, "sdkdev_sdkdev.public.atomtestkeyone")
    sleep(3)
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    sleep(5)
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    sleep(1)
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    sleep(1)
    atom_tracker.track(data3, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    sleep(6)
    #atom_tracker.finalize


  end
def self.test_multitread
  url = "http://track.atom-data.io/"
  atom_tracker = IronSourceAtomTracker.new
  atom_tracker.auth="I40iwPPOsG3dfWX30labriCg9HqMfL"
  a=0
  run_example = true
  (0..5).each do |int|
    Thread.new do
      begin
        while run_example
        data={
            id: a+=1,
            message: "#{int}Thread_array_data"
        }.to_json
        atom_tracker.track(data, "sdkdev_sdkdev.public.atomtestkeyone")
        puts "send data #{data}"
        sleep(0.05)
        if a > 1000
          run_example = false
        end

      end
    end
  end
end
sleep 45
end
  test_multitread
end
