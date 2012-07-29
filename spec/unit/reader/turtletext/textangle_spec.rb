require 'spec_helper'

describe PDF::Reader::Turtletext::Textangle do
  let(:resource_class) { PDF::Reader::Turtletext::Textangle }

  let(:source) { nil } # we're just going to mock the PDF source here
  let(:options) { {} }
  let(:turtletext_reader) { PDF::Reader::Turtletext.new(source,options) }


  describe "#reader" do
    let(:textangle) { resource_class.new(turtletext_reader) }
    subject { textangle.reader }
    it { should be_a(PDF::Reader::Turtletext) }
  end

  describe "#text" do
    let(:page) { 1 }
    before do
      turtletext_reader.stub(:load_content).and_return(given_page_content)
    end
    let(:given_page_content) { {
      70.0=>{10.0=>"crunchy bacon"},
      40.0=>{15.0=>"bacon on kimchi noodles", 25.0=>"heaven"},
      30.0=>{30.0=>"turkey bacon", 35.0=>"fraud"},
      10.0=>{40.0=>"smoked and streaky for me"}
    } }

    it "should work with block param" do
      textangle = resource_class.new(turtletext_reader) do |r|
        r.below = "fraud"
      end
      textangle.below.should eql("fraud")
    end

    it "should work without block param" do
      textangle = resource_class.new(turtletext_reader) do
        below "fraud"
      end
      textangle.below.should eql("fraud")
    end

    context "when only below specified" do
      let(:textangle) { resource_class.new(turtletext_reader) do |r|
        r.below = "fraud"
      end }
      let(:expected) { [["smoked and streaky for me"]]}
      subject { textangle.text }
      it { should eql(expected) }
    end

    context "when only above specified" do
      let(:textangle) { resource_class.new(turtletext_reader) do |r|
        r.above = "heaven"
      end }
      let(:expected) { [["crunchy bacon"]]}
      subject { textangle.text }
      it { should eql(expected) }
    end

    context "when only left_of specified" do
      let(:textangle) { resource_class.new(turtletext_reader) do |r|
        r.left_of = "turkey bacon"
      end }
      let(:expected) { [
        ["crunchy bacon"],
        ["bacon on kimchi noodles", "heaven"]
      ] }
      subject { textangle.text }
      it { should eql(expected) }
    end

    context "when only right_of specified" do
      let(:textangle) { resource_class.new(turtletext_reader) do |r|
        r.right_of = "heaven"
      end }
      let(:expected) { [
        ["turkey bacon","fraud"],
        ["smoked and streaky for me"]
      ] }
      subject { textangle.text }
      it { should eql(expected) }
    end

  end
end