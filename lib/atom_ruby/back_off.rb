module IronSourceAtom
class BackOff
  # Creates a new instance of BackOff.
  # * +min_period+ is the minimum back off time in seconds. The start value for exponential increasing.
  # * +max_period+ is the minimum back off time in seconds. The ceiling value for exponential increasing.
  def initialize (min_period=0.2, max_period=600)
    @retry_count = 0
    @retry_time = min_period
    @min_period = min_period
    @max_period = max_period
    @jitter = Random.new
  end


  # Returns back off time. Each call doubles time value with jitter starting from min_period up to max_period
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
