require 'window'

class GameEngine
  attr_reader :window, :key_callback
  def initialize window_title, width, height, v_sync, logic
    @window = Window.new window_title, width, height, v_sync
    @key_callback = logic
  end

  def run
  end

  def init
    window.init &@key_callback
  end

  def close
    @window.close
  end
end
