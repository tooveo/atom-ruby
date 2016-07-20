require 'thread'
require 'json'
require 'iron_source_atom'
class TestTracker
def self.test_multitread
    url = "http://track.atom-data.io/"
    atom_tracker = IronSourceAtom::Tracker.new
    atom_tracker.auth = "I40iwPPOsG3dfWX30labriCg9HqMfL"
    a=0
    run_example = true
    (0..5).each do |int|
      Thread.new do
        begin
          while run_example
            data = {
                id: a += 1,
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
