
require 'json'
require 'iron_source_atom_tracker'
class TestTracker
  def self.do_test_job
    url = "http://track.atom-data.io/"
    auth = "I40iwPPOsG3dfWX30labriCg9HqMfL"
    atom_tracker = IronSourceAtomTracker.new
    atom_tracker.auth = auth

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
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data2, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data2, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data3, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data3, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.track(data1, "sdkdev_sdkdev.public.atomtestkeyone")
    atom_tracker.finalize


  end
   do_test_job
end