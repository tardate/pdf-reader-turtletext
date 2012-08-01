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

  context "with mock content" do
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

    context "with block param" do
      [:above,:below,:left_of,:right_of].each do |positional_method|
        describe "##{positional_method}" do
          let(:term) { "canary" }

          it "should assign correctly" do
            textangle = resource_class.new(turtletext_reader) do |r|
              r.send("#{positional_method}=",term)
            end
            textangle.send(positional_method).should eql(term)
          end

        end
      end

      describe "#page" do
        let(:value) { 2 }
        describe "default" do
          let(:textangle) { resource_class.new(turtletext_reader) do |r|
          end }
          subject { textangle.page }
          it { should eql(1) }
        end
        it "should assign correctly" do
          textangle = resource_class.new(turtletext_reader) do |r|
            r.page = value
          end
          textangle.page.should eql(value)
        end
      end

      describe "#inclusive" do
        describe "default" do
          let(:textangle) { resource_class.new(turtletext_reader) do |r|
          end }
          subject { textangle.inclusive }
          it { should be_false }
        end
        it "should assign true correctly" do
          textangle = resource_class.new(turtletext_reader) do |r|
            r.inclusive = true
          end
          textangle.inclusive.should be_true
        end
        it "should assign false correctly" do
          textangle = resource_class.new(turtletext_reader) do |r|
            r.inclusive = false
          end
          textangle.inclusive.should be_false
        end
      end
      describe "#inclusive!" do
        it "should assign correctly" do
          textangle = resource_class.new(turtletext_reader) do |r|
            r.inclusive!
          end
          textangle.inclusive.should be_true
        end
      end
      describe "#exclusive!" do
        it "should assign correctly" do
          textangle = resource_class.new(turtletext_reader) do |r|
            r.exclusive!
          end
          textangle.inclusive.should be_false
        end
      end
    end

    context "without block param" do
      it "#above should assign correctly" do
        textangle = resource_class.new(turtletext_reader) do
          above "canary"
        end
        textangle.above.should eql("canary")
      end
      it "#below should assign correctly" do
        textangle = resource_class.new(turtletext_reader) do
          below "canary"
        end
        textangle.below.should eql("canary")
      end
      it "#left_of should assign correctly" do
        textangle = resource_class.new(turtletext_reader) do
          left_of "canary"
        end
        textangle.left_of.should eql("canary")
      end
      it "#below should assign correctly" do
        textangle = resource_class.new(turtletext_reader) do
          right_of "canary"
        end
        textangle.right_of.should eql("canary")
      end

      describe "#page" do
        it "should assign correctly" do
          textangle = resource_class.new(turtletext_reader) do
            page 2
          end
          textangle.page.should eql(2)
        end
      end

      describe "#inclusive" do
        it "should assign true correctly" do
          textangle = resource_class.new(turtletext_reader) do
            inclusive true
          end
          textangle.inclusive.should be_true
        end
        it "should assign false correctly" do
          textangle = resource_class.new(turtletext_reader) do
            inclusive false
          end
          textangle.inclusive.should be_false
        end
      end
      describe "#inclusive!" do
        it "should assign correctly" do
          textangle = resource_class.new(turtletext_reader) do
            inclusive!
          end
          textangle.inclusive.should be_true
        end
      end
      describe "#exclusive!" do
        it "should assign correctly" do
          textangle = resource_class.new(turtletext_reader) do
            exclusive!
          end
          textangle.inclusive.should be_false
        end
      end
    end

    describe "#text" do

      context "when only below specified" do
        context "when exclusive (default)" do
          context "as a string" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.below = "turkey bacon"
            end }
            let(:expected) { [["smoked and streaky for me"]]}
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a regex" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.below = /turkey/i
            end }
            let(:expected) { [["smoked and streaky for me"]]}
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a number" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.below = 30
            end }
            let(:expected) { [["smoked and streaky for me"]]}
            subject { textangle.text }
            it { should eql(expected) }
          end
        end
        context "when inclusive" do
          context "as a string" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.below = "smoked and streaky for me"
            end }
            let(:expected) { [["smoked and streaky for me"]]}
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a regex" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.below = /Streaky/i
            end }
            let(:expected) { [["smoked and streaky for me"]]}
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a number" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.below = 10
            end }
            let(:expected) { [["smoked and streaky for me"]]}
            subject { textangle.text }
            it { should eql(expected) }
          end
        end
        context "when no match" do
          let(:textangle) { resource_class.new(turtletext_reader) do |r|
            r.below = "fake"
          end }
          let(:expected) { [] }
          subject { textangle.text }
          it { should eql(expected) }
        end
      end

      context "when only above specified" do
        context "when exclusive (default)" do
          context "as a string" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.above = "bacon on kimchi noodles"
            end }
            let(:expected) { [["crunchy bacon"]] }
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a regex" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.above = /kimchi/i
            end }
            let(:expected) { [["crunchy bacon"]] }
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a number" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.above = 40
            end }
            let(:expected) { [["crunchy bacon"]] }
            subject { textangle.text }
            it { should eql(expected) }
          end
        end
        context "when inclusive" do
          context "as a string" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.above = "crunchy bacon"
            end }
            let(:expected) { [["crunchy bacon"]] }
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a regex" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.above = /crunChy/i
            end }
            let(:expected) { [["crunchy bacon"]] }
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a number" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.above = 70
            end }
            let(:expected) { [["crunchy bacon"]] }
            subject { textangle.text }
            it { should eql(expected) }
          end
        end
        context "when no match" do
          let(:textangle) { resource_class.new(turtletext_reader) do |r|
            r.above = "fake"
          end }
          let(:expected) { [] }
          subject { textangle.text }
          it { should eql(expected) }
        end
      end

      context "when only left_of specified" do
        context "when exclusive (default)" do
          context "as a string" do
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
          context "as a regex" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.left_of = /turKey/i
            end }
            let(:expected) { [
              ["crunchy bacon"],
              ["bacon on kimchi noodles", "heaven"]
            ] }
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a number" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.left_of = 30
            end }
            let(:expected) { [
              ["crunchy bacon"],
              ["bacon on kimchi noodles", "heaven"]
            ] }
            subject { textangle.text }
            it { should eql(expected) }
          end
        end
        context "when inclusive" do
          context "as a string" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.left_of = "heaven"
            end }
            let(:expected) { [
              ["crunchy bacon"],
              ["bacon on kimchi noodles", "heaven"]
            ] }
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a regex" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.left_of = /heaVen/i
            end }
            let(:expected) { [
              ["crunchy bacon"],
              ["bacon on kimchi noodles", "heaven"]
            ] }
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a number" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.left_of = 25
            end }
            let(:expected) { [
              ["crunchy bacon"],
              ["bacon on kimchi noodles", "heaven"]
            ] }
            subject { textangle.text }
            it { should eql(expected) }
          end
        end
        context "when no match" do
          let(:textangle) { resource_class.new(turtletext_reader) do |r|
            r.left_of = "fake"
          end }
          let(:expected) { [] }
          subject { textangle.text }
          it { should eql(expected) }
        end
      end

      context "when only right_of specified" do
        context "when exclusive (default)" do
          context "as a string" do
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
          context "as a regex" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.right_of = /Heaven/i
            end }
            let(:expected) { [
              ["turkey bacon","fraud"],
              ["smoked and streaky for me"]
            ] }
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a number" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.right_of = 25
            end }
            let(:expected) { [
              ["turkey bacon","fraud"],
              ["smoked and streaky for me"]
            ] }
            subject { textangle.text }
            it { should eql(expected) }
          end
        end
        context "when inclusive" do
          context "as a string" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.right_of = "turkey bacon"
            end }
            let(:expected) { [
              ["turkey bacon","fraud"],
              ["smoked and streaky for me"]
            ] }
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a regex" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.right_of = /turkey/i
            end }
            let(:expected) { [
              ["turkey bacon","fraud"],
              ["smoked and streaky for me"]
            ] }
            subject { textangle.text }
            it { should eql(expected) }
          end
          context "as a number" do
            let(:textangle) { resource_class.new(turtletext_reader) do |r|
              r.inclusive = true
              r.right_of = 30
            end }
            let(:expected) { [
              ["turkey bacon","fraud"],
              ["smoked and streaky for me"]
            ] }
            subject { textangle.text }
            it { should eql(expected) }
          end
        end
        context "when no match" do
          let(:textangle) { resource_class.new(turtletext_reader) do |r|
            r.right_of = "fake"
          end }
          let(:expected) { [] }
          subject { textangle.text }
          it { should eql(expected) }
        end
      end

    end

  end
end