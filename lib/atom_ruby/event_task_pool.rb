require 'thread'
module IronSourceAtom
  class EventTaskPool

    # Creates a new instance of EventTaskPool.
    # * +threads_max_num,+ is the maximum quantity of threads in pool
    # * +events_max_num+ is is the maximum quantity of event tasks in queue.
    def initialize(threads_max_num, events_max_num)
      @threads_max_num = threads_max_num
      @events_max_num = events_max_num
      @event_queue = Queue.new
      (0...@threads_max_num).map do
        Thread.new do
          begin
            work_task
          rescue ThreadError
          end
        end
      end
    end

   private def work_task
      while true
        unless task = @event_queue.pop
          sleep 0.025
          next
        end
        task.call
      end

    end

    # Adds task into task queue. Raises RuntimeError if @event_queue length reaches its maximum
    def add_task(task)
      if @event_queue.length > @events_max_num
        raise "Events task queue is reached maximum length"
      end
      @event_queue.push task
    end
  end
end