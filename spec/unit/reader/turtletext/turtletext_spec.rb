require 'spec_helper'

describe PDF::Reader::Turtletext do
  let(:resource_class) { PDF::Reader::Turtletext }

  let(:source) { nil } # we're just going to mock the PDF source here
  let(:turtletext_reader) { resource_class.new(source,options) }
  let(:options) { {} }

  describe "#reader" do
    subject { turtletext_reader.reader}
    it { should be_a(PDF::Reader) }
  end

  describe "#y_precision" do
    subject { turtletext_reader.y_precision}
    context "default" do
      it { should eql(3) }
    end
    context "when set with options" do
      let(:expected) { 5 }
      let(:options) { { :y_precision => expected } }
      it { should eql(expected) }
    end
  end

  context "with mocked source content" do
    let(:page) { 1 }
    before do
      turtletext_reader.should_receive(:load_content).with(page).and_return(given_page_content)
    end

    {
      :with_simple_text => {
        :source_page_content => {10.0=>{10.0=>"a first bit of text"}},
        :expected_precise_content => {10.0=>{10.0=>"a first bit of text"}},
        :expected_fuzzed_content => [[10.0,[[10.0,"a first bit of text"]]]]
      },
      :with_widely_separated_text => {
        :source_page_content => {20.0=>{10.0=>"a first bit of text"},10.0=>{20.0=>"a second bit of text"}},
        :expected_precise_content => {20.0=>{10.0=>"a first bit of text"},10.0=>{20.0=>"a second bit of text"}},
        :expected_fuzzed_content => [[20.0, [[10.0, "a first bit of text"]]], [10.0, [[20.0, "a second bit of text"]]]]
      },
      :with_unsorted_y_text => {
        :source_page_content => {10.0=>{10.0=>"a first bit of text"},20.0=>{20.0=>"a second bit of text"}},
        :expected_precise_content => {10.0=>{10.0=>"a first bit of text"},20.0=>{20.0=>"a second bit of text"}},
        :expected_fuzzed_content => [[20.0, [[20.0, "a second bit of text"]]], [10.0, [[10.0, "a first bit of text"]]]]
      },
      :with_fuzzed_y_text => {
        :source_page_content => {20.0=>{10.0=>"a first bit of text"},18.0=>{12.0=>"a second bit of text"}},
        :expected_precise_content => {20.0=>{10.0=>"a first bit of text"},18.0=>{12.0=>"a second bit of text"}},
        :expected_fuzzed_content => [[20.0, [[10.0, "a first bit of text"], [[12.0, "a second bit of text"]]]]]
      },
      :with_widely_separated_fuzzed_y_text => {
        :y_precision => 25,
        :source_page_content => {20.0=>{10.0=>"a first bit of text"},10.0=>{20.0=>"a second bit of text"}},
        :expected_precise_content => {20.0=>{10.0=>"a first bit of text"},10.0=>{20.0=>"a second bit of text"}},
        :expected_fuzzed_content => [[20.0, [[10.0, "a first bit of text"], [[20.0, "a second bit of text"]]]]]
      }
    }.each do |test_name,test_expectations|
      context test_name do
        let(:given_page_content) { test_expectations[:source_page_content] }
        let(:options) {
          if (y_precision = test_expectations[:y_precision]) && y_precision != :default
            { :y_precision => y_precision }
          else
            {}
          end
        }

        describe "#content" do
          subject { turtletext_reader.content(page) }
          it { should eql(test_expectations[:expected_fuzzed_content]) }
        end

        describe "#precise_content" do
          subject { turtletext_reader.precise_content(page) }
          it { should eql(test_expectations[:expected_precise_content]) }
        end

      end
    end

    describe "#text_in_region" do
      {
        :with_single_text => {
          :source_page_content => {10.0=>{10.0=>"a first bit of text"}},
          :xmin => 0, :xmax => 100, :ymin => 0, :ymax => 100,
          :expected_text => [["a first bit of text"]]
        },
        :with_single_line_text => {
          :source_page_content => {
            70.0=>{10.0=>"first line ignored"},
            30.0=>{10.0=>"first part found", 20.0=>"last part found"},
            10.0=>{10.0=>"last line ignored"}
          },
          :xmin => 0, :xmax => 100, :ymin => 20, :ymax => 50,
          :expected_text => [["first part found", "last part found"]]
        },
        :with_multi_line_text => {
          :source_page_content => {
            70.0=>{10.0=>"first line ignored"},
            40.0=>{10.0=>"first line first part found", 20.0=>"first line last part found"},
            30.0=>{10.0=>"last line first part found", 20.0=>"last line last part found"},
            10.0=>{10.0=>"last line ignored"}
          },
          :xmin => 0, :xmax => 100, :ymin => 20, :ymax => 50,
          :expected_text => [
            ["first line first part found", "first line last part found"],
            ["last line first part found", "last line last part found"]
          ]
        }
      }.each do |test_name,test_expectations|
        context test_name do
          let(:given_page_content) { test_expectations[:source_page_content] }
          let(:xmin) { test_expectations[:xmin] }
          let(:xmax) { test_expectations[:xmax] }
          let(:ymin) { test_expectations[:ymin] }
          let(:ymax) { test_expectations[:ymax] }
          let(:expected_text) { test_expectations[:expected_text] }
          subject { turtletext_reader.text_in_region(xmin,xmax,ymin,ymax,page) }
          it { should eql(expected_text) }
        end
      end
    end

    describe "#text_position" do
      let(:given_page_content) { {
        70.0=>{10.0=>"crunchy bacon"},
        40.0=>{15.0=>"bacon on kimchi noodles", 25.0=>"heaven"},
        30.0=>{30.0=>"turkey bacon", 35.0=>"fraud"},
        10.0=>{40.0=>"smoked and streaky da bomb"}
      } }
      {
        :with_simple_match => { :match_term => 'turkey bacon', :expected_position => {:x=>30.0, :y=>30.0} },
        :with_match_along_line => { :match_term => 'heaven', :expected_position => {:x=>25.0, :y=>40.0} },
        :with_regex_match => { :match_term => /kimchi/, :expected_position => {:x=>15.0, :y=>40.0} },
        :with_regex_multi_matches_first => { :match_term => /turkey|crunchy/, :expected_position => {:x=>10.0, :y=>70.0} }
      }.each do |test_name,test_expectations|
        context test_name do
          let(:match_term) { test_expectations[:match_term] }
          let(:expected_position) { test_expectations[:expected_position] }
          subject { turtletext_reader.text_position(match_term,page) }
          it { should eql(expected_position) }
        end
      end
    end


  end

end