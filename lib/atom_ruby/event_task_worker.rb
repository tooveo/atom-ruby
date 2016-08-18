require 'celluloid/current'

module IronSourceAtom
  class EventTaskWorker
    include Celluloid

    # Creates a new instance of EventTaskWorker.
    def initialize
      @threads_max_num = 10
      @events_max_num = 1000
    end

     def work_task(event_queue)
      every (0.05) do
        begin
          task = event_queue.pop(true)
          task.call
        rescue Exception => e
          sleep 0.1
        end
      end
    end
  end
end