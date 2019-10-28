require 'window'
require 'timer'

class UnknownRunningStatusError < StandardError
end

class GameEngine
  attr_reader :window, :game_logic, :timer
  attr_accessor :target_fps
  def initialize window_title, width, height, v_sync, logic
    @window = Window.new window_title, width, height, v_sync
    @game_logic = logic
    @timer = Timer.new
    @target_fps = 60
  end

  def run
    self.init
    self.game_loop
  ensure
    self.close
  end

  def init
    @window.init &@game_logic.key_callback
    @game_logic.init
    @timer.init
  end

  def close
    @game_logic.clean_up
    @window.close
  end

  def game_loop
    running = true
    @timer.init
    while running
      interval = 1_000_000 / @target_fps
      accum = @timer.time_elapsed
      while accum < interval
        sleep((interval - accum) / 1_000_000.0)
        accum += @timer.time_elapsed
      end

      running = @game_logic.update(accum)
      raise UnknownRunningStatusError if (running != true && running != false)
    end
  end
end
