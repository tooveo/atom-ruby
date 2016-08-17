require 'celluloid/current'

module IronSourceAtom
  class EventTaskWorker
    include Celluloid

    # Creates a new instance of EventTaskPool.
    # * +threads_max_num,+ is the maximum quantity of threads in pool
    # * +events_max_num+ is is the maximum quantity of event tasks in queue.
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