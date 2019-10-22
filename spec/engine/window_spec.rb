require 'window'

describe Window do
  before :all do
    @window = Window.new "Test", 600, 600, true
  end

  it "should be an instance of window" do
    expect(@window).to be_instance_of Window
  end

  it "should have an init method" do
    expect(@window).to respond_to(:init)
  end

  it "should have a method :glfw_init?" do
    expect(@window).to respond_to(:glfw_init?)
  end

  it "should have a method :close" do
    expect(@window).to respond_to(:close)
  end

  describe "#init" do
    before :all do
      @window.init
    end
    
    it "should have already set an error callback" do
      error_callback = GLFW::create_callback(:GLFWerrorfun) do |i,mess|
        puts "GLFW ERROR: #{i} -- #{mess}"
      end
      ptr = glfwSetErrorCallback(error_callback)
      expect(ptr.to_i).not_to eq 0
    end

    it "should successfully initiate GLFW" do
      expect(@window.glfw_init?).to be true
    end
      
    it "should not have caused an error" do
      err_string = ''
      err = glfwGetError(err_string)
      expect(err).to eq 0
    end
  end

  describe "#close" do
    before :all do
      @window.close
    end

    it "should successfully terminate GLFW" do
      expect(@window.glfw_init?).to be false
    end

    it "should not have caused an error" do
      err_string = ''
      err = glfwGetError(err_string)
      expect(err).to eq 0
    end
  end
end
