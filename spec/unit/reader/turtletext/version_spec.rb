require 'spec_helper'

describe PDF::Reader::Turtletext::Version do
  let(:resource_class) { PDF::Reader::Turtletext::Version }

  it { resource_class::MAJOR.should be_a(Fixnum) }
  it { resource_class::MINOR.should be_a(Fixnum) }
  it { resource_class::PATCH.should be_a(Fixnum) }

  describe "##STRING" do
    subject { resource_class::STRING }
    it { should match(/\d+\.\d+\.\d+/)}
  end
end