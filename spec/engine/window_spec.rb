require 'window'

RSpec.describe Window do
  before :all do
    @title, @width, @height, @v_sync = "Window Test", 600, 400, true
    @window = Window.new(@title, @width, @height, @v_sync)
  end
  subject { @window }

  it { is_expected.to be_instance_of Window }

  it { is_expected.to have_attributes(title: @title) }
  it { is_expected.to have_attributes(width: @width) }
  it { is_expected.to have_attributes(height: @height) }
  it { is_expected.to have_attributes(v_sync: @v_sync) }

  it { is_expected.to respond_to(:init) }
  it { is_expected.to respond_to(:glfw_init?) }
  it { is_expected.to respond_to(:close) }

  describe "#init" do
    before(:all) { @window.init }

    after(:each) { |example| @window.close if example.exception }

    it "should have set an error callback" do
      ptr = glfwSetErrorCallback(subject.error_callback)
      expect(ptr.to_i).not_to eq 0
      expect(ptr.to_i).to eq subject.error_callback.to_i
    end

    it "should successfully initiate GLFW" do
      expect(subject.glfw_init?).to be true
    end

    it "should have created a window" do
      expect(subject.handle).to_not be_nil
    end

    it "should have set a key callback" do
      ptr = glfwSetKeyCallback(subject.handle, subject.key_callback)
      expect(ptr.to_i).not_to eq 0
      expect(ptr.to_i).to eq subject.key_callback.to_i
    end
      
    it "should not have caused an error" do
      err = glfwGetError('')
      expect(err).to eq 0
    end
  end

  describe "#close" do
    before(:all) { @window.close }

    it "should successfully terminate GLFW" do
      expect(subject.glfw_init?).to be false
    end

    it "should have removed the window handle" do
      expect(subject.handle).to be_nil
    end

    it "should not have caused an error" do
      err = glfwGetError('')
      expect(err).to eq 0
    end
  end
end
