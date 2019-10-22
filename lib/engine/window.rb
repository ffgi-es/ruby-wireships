require 'opengl'
require 'glfw'

GLFW.load_lib()

include GLFW

class Window
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
  end

  def glfw_init?
    return @glfw_init
  end

  def close
    glfwTerminate()
    @glfw_init = false
  end
end
