module IronSourceAtom
class BackOff
  def initialize (min_period=0.2, max_period=600)
    @retry_count = 0
    @retry_time = min_period
    @min_period = min_period
    @max_period = max_period
    @jitter = Random.new
  end

  def retry_time
    if @retry_time < @max_period
      time = @jitter.rand * (2**@retry_count - 1)
      @retry_count += 1
      return @retry_time+=time
    else
      return @max_period/2 + @jitter.rand*@max_period
    end


  end
end
end
