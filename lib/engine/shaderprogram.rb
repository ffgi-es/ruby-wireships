require 'opengl'

OpenGL.load_lib

include OpenGL

class ShaderProgromError < StandardError
end

class ShaderProgram
  attr_reader :program_id

  def initialize
    @program_id = glCreateProgram()
  end

  def build_program(sources)
  end

  def bind
  end

  def unbind
  end

  def clean_up
    self.unbind
    if @program_id != 0
      glDeleteProgram(@program_id)
      @program_id = 0
    end
  end

  def createShader source, type
    shader_id = glCreateShader(type)
    raise ShaderProgramError, "Unable to create shader: #{type}" if shader_id == 0

    glShaderSource(shader_id, 1, [source].pack('p'), [source.size].pack('I'))
    
    glCompileShader(shader_id)
    return_buf = ' '*4
    glGetShaderiv(shader_id, GL_COMPILE_STATUS, return_buf)
    return_value = return_buf.unpack('L')
    if return_value == 0
      # ToDo
    end

    glAttachShader(@program_id, shader_id)
end
