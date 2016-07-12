require 'thread'
class EventTaskPool

  def initialize(threads_max_num, events_max_num)
    @threads_max_num = threads_max_num
    @events_max_num = events_max_num
    @event_queue = Queue.new
    workers = (0...@threads_max_num).map do
      Thread.new do
        begin
          work_task
        rescue ThreadError
        end
      end
    end
  end

  def work_task
    while true
      unless task = @event_queue.pop
        sleep 0.025
        next
      end
      task.call
    end

  end
  def add_task(task)
    if @event_queue.length > @events_max_num
      return
    end
    @event_queue.push task
  end
end