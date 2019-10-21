class Window
  def initialize title, width, height, vSync
    @title = title
    @height = height
    @width = width
    @vSync = vSync
  end

  def init
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
