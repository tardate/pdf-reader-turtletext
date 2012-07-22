require 'spec_helper'
include PdfSamplesHelper

describe PDF::Reader::PositionalTextReceiver do
  let(:resource_class) { PDF::Reader::PositionalTextReceiver }

  let(:reader) { PDF::Reader.new(source) }
  let(:receiver) { resource_class.new }
  let(:page) { 1 }

  before do
    reader.page(page).walk(receiver)
  end

  {
    'junk_prefix.pdf' => {747.384=>{36.0=>"This PDF contains junk before the %-PDF marker"}},
    'hello_world.pdf' => {747.384=>{36.0=>"Hello World"}}
  }.each do |sample_file,expected_page_content|
    describe "#content for #{sample_file}" do
      let(:source) { pdf_sample(sample_file) }
      subject { receiver.content }
      it { should eql(expected_page_content) }
    end
  end

end