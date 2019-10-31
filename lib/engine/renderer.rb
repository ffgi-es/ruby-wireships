require 'shaderprogram'

class Renderer
  attr_reader :programs

  def initialize
    @programs = {}
  end

  def load_shaders dir
    files = Dir.children(dir)
    shaders = Hash.new { |h,k| h[k] = [] }
    files.each do |file|
      shader_name = file.match(/(\w+)_(vertex\.vs|geometry\.gs|fragment\.fs)/)[1]
      shaders[shader_name.to_sym] << file
    end
    build_programs dir, shaders
    create_uniforms dir, shaders
  end

  def clean_up
    @programs.values.each { |prog| prog.clean_up }
  end

  def build_programs dir, shaders
    shaders.each do |name, source_files|
      sources = {}
      source_files.each do |file|
        shader_type = file.match(/(\w+)_(vertex\.vs|geometry\.gs|fragment\.fs)/)[2]
        source = File.open([dir,file].join('/')) { |o_file| o_file.read }
        case shader_type
        when "vertex.vs"
          sources[GL_VERTEX_SHADER] = source
        when "geometry.gs"
          sources[GL_GEOMETRY_SHADER] = source
        when "framgent.fs"
          sources[GL_FRAGMENT_SHADER] = source
        end
      end

      shader_program = ShaderProgram.new
      shader_program.build_program sources
      @programs[name] = shader_program
    end
  end

  def create_uniforms dir, shaders
    shaders.each do |name, source_files|
      uniforms = []
      source_files.each do |file|
        File.foreach([dir,file].join('/')) do |line|
          match = line.match(/^uniform.* (\w+);$/)
          uniforms << match[1] if match
        end
      end

      @programs[name].create_uniforms uniforms
    end
  end
end
