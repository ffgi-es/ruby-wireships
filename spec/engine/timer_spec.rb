require 'timer'

describe Timer do
  before(:all) { @timer = Timer.new }
  subject { @timer }

  it { is_expected.to be_instance_of Timer }
  
  describe "attributes" do
    it { is_expected.to have_attributes start_time: an_instance_of(Time) }
    it { is_expected.to have_attributes time_last_call: an_instance_of(Time) }
  end

  describe "methods" do
    it { is_expected.to respond_to :init }
    it { is_expected.to respond_to :time_elapsed }
    it { is_expected.to respond_to :peek_time_elapsed }
  end

  describe "#init" do
    it "should update :time_last_call" do
      initial_time = subject.time_last_call
      subject.init
      expect(subject.time_last_call).to be > initial_time
    end

    it "should update to the time it is called" do
      initial_time = Time.now
      subject.init
      expect(subject.time_last_call).to be > initial_time
    end
  end

  describe "#time_elapsed" do
    it "should return an integer" do
      expect(subject.time_elapsed).to be_instance_of Integer
    end

    it "should be positive" do
      expect(subject.time_elapsed).to be > 0
    end

    it "should measure the time (1 second)" do
      subject.init
      sleep 0.2
      expect(subject.time_elapsed).to be_between(199_000, 201_000).inclusive
    end

    it "should measure the time (0.1 seconds)" do
      subject.init
      sleep 0.1
      expect(subject.time_elapsed).to be_between(99_000, 101_000).inclusive
    end

    it "should update to time it is called" do
      subject.init
      before_call = Time.now
      subject.time_elapsed
      expect(subject.time_last_call).to be > before_call
    end
  end

  describe "#peek_time_elapsed" do
    it "should return an integer" do
      expect(subject.peek_time_elapsed).to be_instance_of Integer
    end

    it "should be positive" do
      expect(subject.peek_time_elapsed).to be > 0
    end

    it "should measure the time (1 second)" do
      subject.init
      sleep 0.2
      expect(subject.peek_time_elapsed).to be_between(199_000, 201_000).inclusive
    end

    it "should measure the time (0.1 seconds)" do
      subject.init
      sleep 0.1
      expect(subject.peek_time_elapsed).to be_between(99_000, 101_000).inclusive
    end

    it "shouldn't update to time it is called" do
      subject.init
      initial_time = subject.time_last_call
      subject.peek_time_elapsed
      expect(subject.time_last_call).to eq initial_time
    end
  end
end
