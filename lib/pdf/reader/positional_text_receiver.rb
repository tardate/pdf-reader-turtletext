# Receiver to access positional (x,y) text content from a PDF
#
# Typical usage:
#
#   reader = PDF::Reader.new(filename)
#   receiver = PDF::Reader::PositionalTextReceiver.new
#   reader.page(page).walk(receiver)
#   receiver.content
#
class PDF::Reader::PositionalTextReceiver < PDF::Reader::PageTextReceiver

  # Override PageTextReceiver content accessor .
  # Returns a hash of positional text:
  #   {
  #     y_coord=>{x_coord=>text, x_coord=>text },
  #     y_coord=>{x_coord=>text, x_coord=>text }
  #   }
  def content
    PDF::Reader::PositionalTextPageLayout.new(@characters, @mediabox).to_pos_hash
  end

end
