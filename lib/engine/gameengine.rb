require 'window'

class GameEngine
  attr_reader :window, :game_logic
  def initialize window_title, width, height, v_sync, logic
    @window = Window.new window_title, width, height, v_sync
    @game_logic = logic
  end

  def run
  end

  def init
    @window.init
    @game_logic.key_callback
  end

  def close
    @window.close
  end
end
