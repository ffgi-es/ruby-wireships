require 'opengl'
require 'glfw'

GLFW.load_lib()

include GLFW

class Window
  attr_reader :title, :height, :width, :vSync, :handle
  def initialize title, width, height, vSync
    @title = title
    @height = height
    @width = width
    @vSync = vSync
  end

  def init
    error_callback = GLFW::create_callback(:GLFWerrorfun) do |int, message|
      STDERR.puts "GLFW ERROR: #{int} -- #{message}"
    end
    glfwSetErrorCallback(error_callback)

    @glfw_init = glfwInit() == GLFW_TRUE

    key_callback = GLFW::create_callback(:GLFWkeyfun) do |wind, key, sccd, act, mod|
      if key == GLFW_KEY_ESCAPE && act = GLFW_PRESS
        glfwSetWindowShouldClose(wind, GLFW_TRUE)
      end
    end

    @handle = glfwCreateWindow(@width, @height, @title, nil, nil)
    glfwSetKeyCallback(@handle, key_callback)
  end

  def glfw_init?
    return @glfw_init
  end

  def close
    glfwDestroyWindow(@handle)
    glfwTerminate()
    @glfw_init = false
  end
end
