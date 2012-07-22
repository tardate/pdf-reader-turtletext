# Class for collating positional text content from a PDF
class PDF::Reader::PositionalTextReceiver < PDF::Reader::PageTextReceiver

  # record text that is drawn on the page
  def show_text(string) # Tj
    raise PDF::Reader::MalformedPDFError, "current font is invalid" if @state.current_font.nil?
    newx, newy = @state.trm_transform(0,0)
    @content[newy] ||= {}
    @content[newy][newx] = @state.current_font.to_utf8(string)
  end

  # override content accessor
  def content
    @content
  end

end
