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
      def clean_up
      end
      def update(interval)
        return false
      end
    end.new

    @game_engine = GameEngine.new(@title, @width, @height, @v_sync, @logic)
  end
  subject { @game_engine }

  it { is_expected.to be_instance_of GameEngine }

  describe "attributes" do
    it { is_expected.to have_attributes(window: an_instance_of(Window)) }
    it { is_expected.to have_attributes(game_logic: @logic) }
    it { is_expected.to have_attributes(timer: an_instance_of(Timer)) }
    it { is_expected.to have_attributes(target_fps: 60) }
  end

  describe "methods" do
    it { is_expected.to respond_to(:init) }
    it { is_expected.to respond_to(:close) }
    it { is_expected.to respond_to(:run) }
    it { is_expected.to respond_to(:game_loop) }
    it { is_expected.to respond_to(:target_fps=) }
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
      expect(subject.timer).to receive(:init)
      subject.init
    end

    it "should have initialised the window" do
      expect(subject.window.handle).to_not be_nil
    end
  end

  describe "#close" do
    before(:all) { @game_engine.close }

    it "should close its attributes" do
      expect(subject.game_logic).to receive(:clean_up)
      expect(subject.window).to receive(:close)
      subject.close
    end

    it "should have destroyed the window" do
      expect(subject.window.handle).to be_nil
    end
  end

  describe "#run" do
    it "should call its own methods to open and close" do
      is_expected.to receive(:init)
      is_expected.to receive(:close)
      is_expected.to receive(:game_loop)
      subject.run
    end
  end

  describe "#game_loop" do
    it "should update game_logic with an integer time_interval" do
      expect(subject.game_logic).to receive(:update).
        with(an_instance_of Integer).and_call_original
      subject.game_loop
    end

    it "should raise an error if game_logic.update doesn't return true or false" do
      logic = Class.new do
        def update interval
        end
      end.new
      engine = GameEngine.new("Title",600,600,true,logic)

      expect { engine.game_loop }.to raise_error UnknownRunningStatusError
    end

    it "should call update repeatedly until false is returned" do
      num = rand(5)+5
      logic = Class.new do
        def initialize n
          @count, @num = 0, n
        end
        def update interval
          @count += 1
          @count < @num
        end
      end.new num
      engine = GameEngine.new("Title",600,600,true,logic)

      expect(engine.game_logic).to receive(:update).exactly(num).times.and_call_original

      engine.game_loop
    end

    it "should update at the target fps" do
      logic = Class.new do
        def initialize
          @count = 0
        end
        def update interval
          @count += 1
          @count < 5
        end
      end.new
      engine = GameEngine.new("Title",600,600,true,logic)

      tar_int = 1_000_000 / engine.target_fps
      err = 500

      expect(engine.game_logic).to receive(:update).exactly(5).times.
        with(be_between(tar_int - err, tar_int + err)).and_call_original

      engine.game_loop
    end

    it "should pass the correct time interval" do
      logic = Class.new do
        attr_reader :diff
        def initialize
          @count = 0
          @timer = Timer.new
        end
        def update interval
          @count += 1
          case @count
          when 1
            @timer.init
            return true
          when 2
            @diff = interval - @timer.time_elapsed
            return false
          end
        end
      end.new
      engine = GameEngine.new("Title",600,600,true,logic)

      engine.game_loop

      expect(logic.diff.abs).to be_between(0,500)
    end
  end
end
