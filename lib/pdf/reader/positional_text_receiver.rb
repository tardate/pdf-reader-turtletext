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

  # record text that is drawn on the page
  def show_text(string) # Tj
    raise PDF::Reader::MalformedPDFError, "current font is invalid" if @state.current_font.nil?
    newx, newy = @state.trm_transform(0,0)
    @content[newy] ||= {}
    @content[newy][newx] ||= ''
    @content[newy][newx] << @state.current_font.to_utf8(string)
  end

  # override PageTextReceiver content accessor .
  # Returns a hash of positional text:
  #   {
  #     y_coord=>{x_coord=>text, x_coord=>text },
  #     y_coord=>{x_coord=>text, x_coord=>text }
  #   }
  def content
    @content
  end

end
