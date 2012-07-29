require 'spec_helper'
include PdfSamplesHelper

describe "PDF Samples" do

  # This will scan all *.pdf files in spec/fixtures/personal_pdf_samples
  # and do basic verification of the file structure without any effort from you.
  pdf_sample_expectations.each do |sample_name,test_specifications|
    describe "sample" do
      let(:options) { test_specifications[:options] || {} }
      let(:sample_file) { pdf_sample(sample_name) }
      let(:turtletext_reader) { PDF::Reader::Turtletext.new(sample_file,options) }

      (test_specifications||{}).each do |test_name,expectations|
        context test_name do
          let(:bounding_box) {
            turtletext_reader.bounding_box do
              above expectations[:above]
              below expectations[:below]
              left_of expectations[:left_of]
              right_of expectations[:right_of]
            end
          }
          # it {
          #   puts "bounding_box"
          #   puts bounding_box.inspect
          # }
          subject { bounding_box.text }
          it { should eql(expectations[:expected_text])}
        end
      end
    end
  end

end
