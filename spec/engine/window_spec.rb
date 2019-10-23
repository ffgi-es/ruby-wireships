require 'window'

describe Window do
  before :all do
    @title = "Window Test"
    @width = 600
    @height = 400
    @v_sync = true
    @window = Window.new @title, @width, @height, @v_sync
  end

  it "should be an instance of window" do
    expect(@window).to be_instance_of Window
  end

  context "checking it has the expected methods" do
    it "should have an init method" do
      expect(@window).to respond_to(:init)
    end

    it "should have a method to check glfw initialised" do
      expect(@window).to respond_to(:glfw_init?)
    end

    it "should have a close method" do
      expect(@window).to respond_to(:close)
    end
  end

  context "checking it has expected attributes" do
    it "should have the title given to the constructor" do
      expect(@window.title).to eq @title
    end

    it "should be #{@width} wide" do
      expect(@window.width).to eq @width
    end

    it "should be #{@height} high" do
      expect(@window.height).to eq @height
    end

    it "should have v_sync set to #{@v_sync}" do
      expect(@window.v_sync).to eq @v_sync
    end
  end

  describe "#init" do
    before :all do
      @window.init
    end
    
    it "should have set an error callback" do
      ptr = glfwSetErrorCallback(@window.error_callback)
      expect(ptr.to_i).not_to eq 0
      expect(ptr.to_i).to eq @window.error_callback.to_i
    end

    it "should successfully initiate GLFW" do
      expect(@window.glfw_init?).to be true
    end

    it "should have created a window" do
      expect(@window.handle).to_not be_nil
    end

    it "should have set a key callback" do
      ptr = glfwSetKeyCallback(@window.handle, @window.key_callback)
      expect(ptr.to_i).not_to eq 0
      expect(ptr.to_i).to eq @window.key_callback.to_i
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
