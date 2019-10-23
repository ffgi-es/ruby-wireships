require 'window'

class GameEngine
  attr_reader :window
  def initialize window_title, width, height, v_sync
    @window = Window.new window_title, width, height, v_sync
  end

  def run
  end

  def init
    @window.init
  end

  def close
    @window.close
  end
end
