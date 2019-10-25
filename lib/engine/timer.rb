require 'time'

class Timer
  attr_reader :start_time, :time_last_call

  def initialize
    @start_time = Time.now
    @time_last_call = @start_time
  end

  def init
    @time_last_call = Time.now
  end

  def time_elapsed
    now = Time.now
    result = (now - @time_last_call) * 1_000_000
    @time_last_call = now
    return result.to_i
  end

  def peek_time_elapsed
    now = Time.now
    return ((now - @time_last_call) * 1_000_000).to_i
  end
end
