# A DSL syntax for text extraction.
# WIP - not using this yet
#
# textangle = PDF::Reader::Textangle.new(reader) do
#   page 1
#   below "Electricity Services"
#   above "Gas Services by City Gas Pte Ltd"
#   right_of 240.0
#   left_of "Total ($)"
# end
# textangle.text
#
class PDF::Reader::Turtletext::Textangle
  attr_reader :reader
  attr_writer :page,:above,:below,:left_of,:right_of

  # +structured_reader+ is a PDF::StructuredReader
  def initialize(structured_reader,&block)
    @reader = structured_reader
    instance_eval( &block ) if block
  end

  def text
    # TODO
  end

end
