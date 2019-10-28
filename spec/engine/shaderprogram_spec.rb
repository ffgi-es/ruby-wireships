require 'shaderprogram'
require 'window'

describe ShaderProgram do
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
end
