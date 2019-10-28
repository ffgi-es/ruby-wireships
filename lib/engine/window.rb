require 'opengl'
require 'glfw'

GLFW.load_lib
OpenGL.load_lib

include GLFW
include OpenGL

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

    set_window_hints

    @handle = glfwCreateWindow(@width, @height, @title, nil, nil)

    if block_given?
      set_key_callback &key_callback
    else
      set_key_callback
    end

    set_gl_options
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

  def set_window_hints
    glfwDefaultWindowHints()
    glfwWindowHint(GLFW_VISIBLE, GLFW_FALSE)
    glfwWindowHint(GLFW_FLOATING, GLFW_TRUE)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MAJOR, 3)
    glfwWindowHint(GLFW_CONTEXT_VERSION_MINOR, 2)
    glfwWindowHint(GLFW_OPENGL_PROFILE, GLFW_OPENGL_CORE_PROFILE)
    glfwWindowHint(GLFW_OPENGL_FORWARD_COMPAT, GLFW_TRUE)
  end

  def set_gl_options
    glfwMakeContextCurrent(@handle)
    glfwShowWindow(@handle)

    puts "OpenGl Version: #{glGetString(GL_VERSION)}"
    
    glClearColor(0.0, 0.0, 0.0, 0.0)
    glEnable(GL_BLEND)
    glDisable(GL_CULL_FACE)
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA)
  end
end
