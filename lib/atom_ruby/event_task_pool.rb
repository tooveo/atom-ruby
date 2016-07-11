require 'thread'
class EventTaskPool

  def initialize(threads_max_num)
    @threads_max_num = threads_max_num
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
      yield
  end
end