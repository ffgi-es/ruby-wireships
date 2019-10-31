require 'shaderprogram'
require 'window'

describe ShaderProgram do
  def create_working_program
    prog = ShaderProgram.new
    vertex_source = File.open("test/shaders/test_vertex.vs") { |f| f.read }
    fragment_source = File.open("test/shaders/test_fragment.fs") { |f| f.read }
    shaders = { GL_VERTEX_SHADER => vertex_source,
                GL_FRAGMENT_SHADER => fragment_source }
    prog.build_program(shaders)
    return prog
  rescue StandardError => e
    prog.clean_up
    raise e
  end

  def create_with_uniforms uniforms
    prog = create_working_program
    prog.create_uniforms uniforms
    return prog
  rescue StandardError => e
    prog.clean_up
    raise e
  end

  before :all do
    @window = Window.new "ShaderProgram Test", 600, 600, true
    @window.init
    @s_prog = ShaderProgram.new
  end

  after :each do |example|
    if example.exception
      @s_prog.clean_up 
      @window.close
    end
  end

  after :all do 
    @s_prog.clean_up
    @window.close
  end

  subject { @s_prog }

  it { is_expected.to be_instance_of ShaderProgram }

  describe "attributes" do
    it { is_expected.to have_attributes(program_id: a_value > 0) }
    it { is_expected.to have_attributes(uniforms: {}) }
  end

  describe "methods" do
    it { is_expected.to respond_to(:build_program) }
    it { is_expected.to respond_to(:bind) }
    it { is_expected.to respond_to(:unbind) }
    it { is_expected.to respond_to(:clean_up) }
    it { is_expected.to respond_to(:create_uniforms) }
    it { is_expected.to respond_to(:set_uniforms) }
  end

  describe "#build_program" do
    it "should accept a hash of shaders" do
      begin
        prog = nil
        expect{ prog = create_working_program }.to_not raise_error
      ensure
        prog.clean_up
      end
    end

    it "should raise an error if given incorrect shader code" do
      begin
        prog = ShaderProgram.new
        vertex_source = <<~SRC
          #version 330
          layout (location=0) in vec2 position;
          uniform mat2 PVWMatrix;
          void main() {
            vec2 pos = Matrix * position;
            gl_Position = vec4(pos, 0.0, 1.0);
          }
        SRC
        shaders = { GL_VERTEX_SHADER => vertex_source }
        expect{ prog.build_program(shaders) }.to raise_error(
          ShaderProgramError, /compiling/)
      ensure
        prog.clean_up if prog
      end
    end

    it "should raise an error if there is a problem linking" do
      begin
        prog = ShaderProgram.new
        vertex_source = <<~SRC
          #version 330
          layout (location=0) in vec2 position;
          layout (location=1) in vec3 colour;
          uniform mat2 PVWMatrix;
          out vec3 fgColour;
          void main() {
            vec2 pos = PVWMatrix * position;
            gl_Position = vec4(pos, 0.0, 1.0);
            fgColour = colour;
          }
        SRC
        fragment_source = <<~SRC
          #version 330
          in ivec4 fColour;
          out vec4 fragColour;
          void main () {
            fragColour = fColour;
          }
        SRC
        shaders = { GL_VERTEX_SHADER => vertex_source,
                    GL_FRAGMENT_SHADER => fragment_source }
        expect{ prog.build_program(shaders) }.to raise_error(
          ShaderProgramError, /linking/)
      ensure
        prog.clean_up if prog
      end
    end
  end

  describe "#clean_up" do
    it "should call glDeleteProgram" do
      prog = ShaderProgram.new
      prog.clean_up
      expect(prog.program_id).to eq 0
    end
  end

  describe "#create_uniforms" do
    it "should create a hash of uniform locations" do
      begin
        prog = create_with_uniforms ["PVWMatrix"]
        expect(prog.uniforms.size).to eq 1
        expect(prog.uniforms["PVWMatrix"][:location]).to_not be_nil
        expect(prog.uniforms["PVWMatrix"][:type]).to eq GL_FLOAT_MAT2
      ensure
        prog.clean_up if prog
      end
    end

    it "should throw an error if uniform doesn't exist" do
      expect{ create_with_uniforms ["not_exist"] }.to raise_error(
        ShaderProgramError, /Uniform:.*not found/)
    end
  end

  describe "#set_uniforms" do
    def create_with_uniform_and_set name, value
      prog = create_with_uniforms [name]
      prog.bind
      prog.set_uniforms name => value
      return prog
    rescue StandardError => e
      prog.clean_up if prog
      raise e
    end

    it "should set uniforms when given a hash of values for a mat2" do
      begin
        prog = create_with_uniform_and_set "PVWMatrix", [1,2,3,4]

        return_buf = ' ' * 4 * 4
        glGetUniformfv(prog.program_id, prog.uniforms["PVWMatrix"][:location], return_buf)
        return_values = return_buf.unpack('F*')
        expect(return_values).to eq [1,2,3,4]
      ensure
        prog.clean_up if prog
      end
    end

    it "should set uniform when given a hash of values for vec2" do
      begin
        prog = create_with_uniform_and_set "offset", [1,2]

        return_buf = ' ' * 4 * 2
        glGetUniformfv(prog.program_id, prog.uniforms["offset"][:location], return_buf)
        return_value = return_buf.unpack('F*')
        expect(return_value).to eq [1,2]
      ensure
        prog.clean_up if prog
      end
    end

    it "should set uniform when given a hash of values for a float" do
      begin
        prog = create_with_uniform_and_set "colourShift", 1

        return_buf = ' ' * 4
        glGetUniformfv(prog.program_id, 
                       prog.uniforms["colourShift"][:location], return_buf)
        return_value = return_buf.unpack('F').first
        expect(return_value).to eq 1
      ensure
        prog.clean_up if prog
      end
    end

    it "should set uniform when given a hash of values for an int" do
      begin
        prog = create_with_uniform_and_set "screenwidth", 300

        return_buf = ' ' * 4
        glGetUniformiv(prog.program_id,
                       prog.uniforms["screenwidth"][:location], return_buf)
        return_value = return_buf.unpack('L').first
        expect(return_value).to eq 300
      ensure
        prog.clean_up if prog
      end
    end

    it "should set all uniforms in the hash" do
      begin
        prog = create_with_uniforms ["PVWMatrix", "offset", "screenwidth"]
        prog.bind
        uniforms = { "PVWMatrix" => [12,13,14,15],
                     "offset" => [4,7],
                     "screenwidth" => 234 }
        prog.set_uniforms uniforms

        matrix_buf = ' ' * 4 * 4
        vec2_buf = ' ' * 4 * 2
        int_buf = ' ' * 4
        glGetUniformfv(prog.program_id,
                       prog.uniforms["PVWMatrix"][:location], matrix_buf)
        glGetUniformfv(prog.program_id,
                       prog.uniforms["offset"][:location], vec2_buf)
        glGetUniformiv(prog.program_id,
                       prog.uniforms["screenwidth"][:location], int_buf)
        matrix_values = matrix_buf.unpack('FFFF')
        vec2_values = vec2_buf.unpack('FF')
        int_value = int_buf.unpack('L').first

        expect(matrix_values).to eq [12,13,14,15]
        expect(vec2_values).to eq [4,7]
        expect(int_value).to eq 234
      ensure
        prog.clean_up if prog
      end
    end

    it "should raise an error if a uniform doesn't exist" do
      begin
        prog = create_with_uniforms ["PVWMatrix"]
        prog.bind
        expect{ prog.set_uniforms "pvwmatrix" => [2,3,4,5] }.to raise_error(
          ShaderProgramError, /Uniform:.*doesn't exist/)
      ensure
        prog.clean_up if prog
      end
    end
  end

  describe "#bind" do
    it "should set the current program to itself" do
      begin
        prog = create_working_program
        prog.bind

        return_buf = ' ' * 4
        glGetIntegerv(GL_CURRENT_PROGRAM, return_buf)
        return_value = return_buf.unpack('L').first
        expect(return_value).to eq prog.program_id
      ensure
        prog.clean_up if prog
      end
    end
  end

  describe "#unbind" do
    it "should set the current program to zero" do
      begin
        prog = create_working_program
        prog.bind
        prog.unbind

        return_buf = ' ' * 4
        glGetIntegerv(GL_CURRENT_PROGRAM, return_buf)
        return_value = return_buf.unpack('L').first
        expect(return_value).to eq 0
      ensure
        prog.clean_up if prog
      end
    end
  end
end
