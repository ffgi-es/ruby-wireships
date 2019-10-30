require 'opengl'

OpenGL.load_lib

include OpenGL

class ShaderProgramError < StandardError
end

class ShaderProgram
  attr_reader :program_id, :uniforms

  def initialize
    @program_id = glCreateProgram()
    @uniforms = Hash.new { |hash, key| hash[key] = {} }
  end

  def build_program(sources)
    @shaders = []
    sources.each { |type, source| @shaders << self.create_shader(type, source)}
    glLinkProgram(@program_id)
    check_error(@program_id, GL_LINK_STATUS)
    @shaders.each { |shader| glDetachShader(@program_id, shader) }
    check_error(@program_id, GL_VALIDATE_STATUS)
  end

  def create_uniforms uniform_names
    uniform_names.each do |name|
      location = glGetUniformLocation(@program_id, name)
      raise ShaderProgramError, "Uniform: #{name} not found" if location < 0
      uniforms[name][:location] = location

      type_buf = ' ' * 4
      length_buf = ' ' * 4
      size_buf = ' ' * 4
      glGetActiveUniform(@program_id, location, 0, length_buf, size_buf, type_buf, nil)
      type_value = type_buf.unpack('L').first
      uniforms[name][:type] = type_value
    end
  end

  def set_uniforms uniforms
    uniforms.each do |name, value|
    end
  end

  def bind
    glUseProgram(@program_id)
  end

  def unbind
    glUseProgram(0)
  end

  def clean_up
    self.unbind
    @shaders.each { |shader_id| glDeleteShader(shader_id) } if @shaders
    if @program_id != 0
      glDeleteProgram(@program_id)
      @program_id = 0
    end
  end

  def create_shader type, source
    shader_id = glCreateShader(type)
    raise ShaderProgramError, "Unable to create shader: #{type}" if shader_id == 0

    glShaderSource(shader_id, 1, [source].pack('p'), [source.size].pack('I'))
    glCompileShader(shader_id)
    check_error(shader_id, GL_COMPILE_STATUS)
    glAttachShader(@program_id, shader_id)
    return shader_id
  end

  def check_error id, type
    refs = { GL_COMPILE_STATUS => ['Shader', 'Error compiling shader'],
             GL_LINK_STATUS => ['Program', 'Error linking program'],
             GL_VALIDATE_STATUS => ['Program', 'Error validating program'] }
    call_type, error_type = refs[type]

    return_buf = ' ' * 4
    send("glGet#{call_type}iv", id, type, return_buf)

    return_value = return_buf.unpack('L').first
    if return_value == GL_FALSE
      log_buf = ' ' * 10240
      length_buf = ' ' * 4
      send("glGet#{call_type}InfoLog", id, 10239, length_buf, log_buf)
      message = "#{error_type}\nLog:\n#{log_buf}"
      raise ShaderProgramError, message
    end
  end
end
