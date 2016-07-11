require 'thread'
class EventTaskPool

  def initialize(threads_max_num, events_max_num)
    @threads_max_num = threads_max_num
    @events_max_num = events_max_num
    @events_actions = Queue.new
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
    while (true)
      if !event_action = @events_actions.pop(true)
        sleep(0.025)
        next
      end
      event_action
    end
  end

  def add_event(event_action) 
    if @events_actions.length> @events_max_num_

    return
    end
    @events_actions.push event_action
  end
end