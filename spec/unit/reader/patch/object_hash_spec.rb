require 'spec_helper'
include PdfSamplesHelper

describe PDF::Reader::ObjectHash do

  context "when there is a junk prefix" do
    let(:sample_name) { pdf_sample('junk_prefix.pdf') }
    let(:object_hash) { PDF::Reader::ObjectHash.new(sample_name) }
    let(:stream) { object_hash.instance_variable_get(:@io) }
    before { stream.rewind }
    subject { stream.read(4) }
    it { should eql("%PDF") }
  end

end
