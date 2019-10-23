require 'gameengine'

describe GameEngine do
  before :all do
    @title = "GameEngine Test"
    @width = 600
    @height = 600
    @v_sync = true

    @gameengine = GameEngine.new @title, @width, @height, @v_sync
  end

  after :all do
    @gameengine.close
  end

  it "should be an instance of GameEngine" do
    expect(@gameengine).to be_instance_of GameEngine
  end

  context "checking attributes" do
    it "should have a window" do
      expect(@gameengine.window).to_not be_nil
    end

    context "checking the window" do
      it "should have the title: #{@title}" do
        expect(@gameengine.window.title).to eq @title
      end

      it "should be #{@width} wide" do
        expect(@gameengine.window.width).to eq @width
      end

      it "should be #{@height} high" do
        expect(@gameengine.window.height).to eq @height
      end

      it "should have v_sync set to #{@v_sync}" do
        expect(@gameengine.window.v_sync).to eq @v_sync
      end
    end
  end

  context "checking methods" do
    it "should respond to :init" do
      expect(@gameengine).to respond_to(:init)
    end

    it "should respond to :close" do
      expect(@gameengine).to respond_to(:close)
    end

    it "should respond to :run" do
      expect(@gameengine).to respond_to(:run)
    end
  end

  describe "#init" do
    before :all do
      @gameengine.init
    end

    it "should have initialised the window" do
      expect(@gameengine.window.handle).to_not be_nil
    end
  end

  describe "#close" do
    before :all do
      @gameengine.close
    end

    it "should have destroyed the window" do
      expect(@gameengine.window.handle).to be_nil
    end
  end
end
