require 'shaderprogram'
require 'window'

describe ShaderProgram do
  def create_working_program
    prog = ShaderProgram.new
    vertex_source = <<~SRC
          #version 330
          layout (location=0) in vec2 position;
          layout (location=1) in vec3 colour;
          out vec4 fColour;
          uniform mat2 PVWMatrix;
          void main() {
            vec2 pos = PVWMatrix * position;
            gl_Position = vec4(pos, 0.0, 1.0);
            fColour = vec4(colour, 1.0);
          }
    SRC
    fragment_source = <<~SRC
          #version 330
          in vec4 fColour;
          out vec4 fragColour;
          void main () {
            fragColour = fColour;
          }
    SRC
    shaders = { GL_VERTEX_SHADER => vertex_source,
                GL_FRAGMENT_SHADER => fragment_source }
    prog.build_program(shaders)
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
  end

  describe "methods" do
    it { is_expected.to respond_to(:build_program) }
    it { is_expected.to respond_to(:bind) }
    it { is_expected.to respond_to(:unbind) }
    it { is_expected.to respond_to(:clean_up) }
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
        prog.clean_up
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
        prog.clean_up
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
        prog.clean_up
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
        prog.clean_up
      end
    end
  end
end
