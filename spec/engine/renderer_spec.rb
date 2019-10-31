require 'renderer'
require 'window'

describe Renderer.new do
  def window
    @window ||= Window.new "Renderer Test", 600, 600, true
  end

  before(:all) { window.init }
  after(:all) { window.close }

  after :each do 
    subject.clean_up
  end

  it { is_expected.to be_instance_of Renderer }

  describe "attributes" do
    it { is_expected.to have_attributes(programs: {}) }
  end

  describe "methods" do
    it { is_expected.to respond_to(:load_shaders) }
    it { is_expected.to respond_to(:clean_up) }
  end

  describe "#load_shaders" do
    it "should accept a directory and load all shaders" do
      subject.load_shaders "test/shaders"
      expect(subject.programs[:test]).to be_instance_of ShaderProgram
    end

    it "should automatically create the uniforms" do
      subject.load_shaders "test/shaders"
      prog = subject.programs[:test]
      expect(prog.uniforms.size).to eq 4
      expect(prog.uniforms["PVWMatrix"][:location]).to_not be_nil
      expect(prog.uniforms["offset"][:location]).to_not be_nil
      expect(prog.uniforms["colourShift"][:location]).to_not be_nil
      expect(prog.uniforms["screenwidth"][:location]).to_not be_nil
    end
  end

  describe "#clean_up" do
    it "should clean up all the shader programs" do
      subject.load_shaders "test/shaders"
      subject.clean_up
      subject.programs.values.each do |prog|
        expect(prog.program_id).to eq 0
      end
    end
  end
end
