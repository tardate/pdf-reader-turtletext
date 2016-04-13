# Receiver to access positional (x,y) text content from a PDF
#
# Typical usage:
#
#   reader = PDF::Reader.new(filename)
#   receiver = PDF::Reader::TransposedPositionalTextReceiver.new
#   reader.page(page).walk(receiver)
#   receiver.content
#
class PDF::Reader::TransposedPositionalTextReceiver < PDF::Reader::PositionalTextReceiver

  # record text that is drawn on the page
  def show_text(string) # Tj
    raise PDF::Reader::MalformedPDFError, "current font is invalid" if @state.current_font.nil?
    newx, newy = @state.trm_transform(0,0)
    @content[newx] ||= {}
    @content[newx][newy] ||= ''
    @content[newx][newy] << @state.current_font.to_utf8(string)
  end

  # override PageTextReceiver content accessor .
  # Returns a hash of positional text:
  #   {
  #     x_coord=>{y_coord=>text, y_coord=>text },
  #     x_coord=>{y_coord=>text, y_coord=>text }
  #   }
  def content
    super
  end

end
