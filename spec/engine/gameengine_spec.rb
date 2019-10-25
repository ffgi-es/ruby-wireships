require 'gameengine'

describe GameEngine do
  before :all do
    @title, @width, @height, @v_sync = "GameEngine Test", 600, 400, true
    @logic = Class.new do
      def key_callback
        Proc.new {|wind,key,sccd,act,mod|}
      end
      def init
      end
    end.new

    @game_engine = GameEngine.new(@title, @width, @height, @v_sync, @logic)
  end
  subject { @game_engine }

  it { is_expected.to be_instance_of GameEngine }

  describe "attributes" do
    it { is_expected.to have_attributes(window: an_instance_of(Window)) }
    it { is_expected.to have_attributes(game_logic: @logic) }
  end

  describe "methods" do
    it { is_expected.to respond_to(:init) }
    it { is_expected.to respond_to(:close) }
    it { is_expected.to respond_to(:run) }
  end

  describe "window attributes" do
    subject { GameEngine.new(@title, @width, @height, @v_sync, @test_logic).window }
    it { is_expected.to have_attributes(title: @title) }
    it { is_expected.to have_attributes(height: @height) }
    it { is_expected.to have_attributes(width: @width) }
    it { is_expected.to have_attributes(v_sync: @v_sync) }
  end


  describe "#init" do
    before(:all) { @game_engine.init }
    after(:each) { |example| @game_engine.close if example.exception }

    it "should initialise its attributes" do
      expect(subject.game_logic).to receive(:key_callback).and_call_original
      expect(subject.window).to receive(:init) do |&block|
        expect(block).to_not be_nil
      end
      expect(subject.game_logic).to receive(:init)
      subject.init
    end

    it "should have initialised the window" do
      expect(subject.window.handle).to_not be_nil
    end
  end

  describe "#close" do
    before(:all) { @game_engine.close }

    it "should have destroyed the window" do
      expect(subject.window.handle).to be_nil
    end
  end
end
