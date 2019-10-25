require 'opengl'
require 'glfw'

GLFW.load_lib()

include GLFW

class Window
  attr_reader :title, :height, :width, :v_sync, :handle
  attr_reader :error_callback, :key_callback
  def initialize title, width, height, v_sync
    @title = title
    @height = height
    @width = width
    @v_sync = v_sync
  end

  def init &key_callback
    set_error_callback

    @glfw_init = glfwInit() == GLFW_TRUE

    @handle = glfwCreateWindow(@width, @height, @title, nil, nil)

    if block_given?
      set_key_callback &key_callback
    else
      set_key_callback
    end
  end

  def glfw_init?
    return @glfw_init
  end

  def close
    glfwDestroyWindow(@handle) unless @handle.nil?
    @handle = nil
    glfwTerminate()
    @glfw_init = false
  end

  private
  def set_error_callback
    @error_callback = GLFW::create_callback(:GLFWerrorfun) do |int, message|
      STDERR.puts "GLFW ERROR: #{int} -- #{message}"
    end
    glfwSetErrorCallback(@error_callback)
  end

  def set_key_callback
    @key_callback = GLFW::create_callback(:GLFWkeyfun) do |wind, key, sccd, act, mod|
      if key == GLFW_KEY_ESCAPE && act = GLFW_PRESS
        glfwSetWindowShouldClose(wind, GLFW_TRUE)
      end
      yield wind, key, sccd, act, mod
    end
    glfwSetKeyCallback(@handle, @key_callback)
  end
end
