# Class for reading structured text content
# This is the one that is a bit hairy - specifically check the fuzzed_y usage
# which attempts to align text content in the PDF so it can be extracted
# with correct alignment.
#
class PDF::Reader::Turtletext::StructuredReader
  attr_reader :reader

  # +source+ is a file name or stream-like object
  def initialize(source)
    @reader = PDF::Reader.new(source)
  end

  # Returns positional (with fuzzed y positioning) text content collection as a hash:
  # { y_position: { x_position: content}}
  def content(page=1)
    @content ||= []
    if @content[page]
      @content[page]
    else
      @content[page] = fuzzed_y(precise_content(page))
    end
  end

  # Returns a hash with fuzzed y positioning:
  # { fuzzed_y_position: { x_position: content}}
  # Given +input+ as a hash:
  # { y_position: { x_position: content}}
  # y values that fall within +precision+ points of another will be clustered
  def fuzzed_y(input,precision=3)
    output = {}
    input.keys.sort.each do |precise_y|
      # matching_y = (precise_y / 5.0).truncate * 5.0
      matching_y = output.keys.select{|new_y| (new_y - precise_y).abs < precision }.first || precise_y
      output[matching_y] ||= {}
      output[matching_y].merge!(input[precise_y])
    end
    output
  end

  # Returns positional text content collection as a hash with precise x,y positioning:
  # { y_position: { x_position: content}}
  def precise_content(page=1)
    @precise_content ||= []
    if @precise_content[page]
      @precise_content[page]
    else
      @precise_content[page] = load_content(page)
    end
  end

  # Returns an array of text elements in the bounding box
  def text_in_rect(xmin,xmax,ymin,ymax,page=1)
    text_map = content(page)
    box = []
    text_map.keys.sort.reverse.each do |y|
      if y >= ymin && y<= ymax
        row = []
        text_map[y].keys.sort.each do |x|
          if x >= xmin && x<= xmax
            row << text_map[y][x]
          end
        end
        box << row unless row.empty?
      end
    end
    box
  end

  # Returns the position {x: val, y: val } of +text+ on +page+
  # +text+ may be  astring (exact match required) or a Regexp
  def text_position(text,page=1)
    item = if text.class <= Regexp
      content(page).map {|k,v| if x = v.reduce(nil){|memo,vv|  memo = (vv[1] =~ text) ? vv[0] : memo  } ; [k,x] ; end }
    else
      content(page).map {|k,v| if x = v.rassoc(text) ; [k,x] ; end }
    end
    item = item.compact.flatten
    unless item.empty?
      { :x => item[1], :y => item[0] }
    end
  end

  # WIP - not using Textangle yet for text extraction.
  # Ideal usage is something like this:
  #
  # textangle = reader.bounding_box do
  #   page 1
  #   below "Electricity Services"
  #   above "Gas Services by City Gas Pte Ltd"
  #   right_of 240.0
  #   left_of "Total ($)"
  # end
  # textangle.text
  #
  def bounding_box(&block)
    PDF::Reader::Textangle.new(self,&block)
  end

  private

    def load_content(page)
      receiver = PDF::Reader::PositionalTextReceiver.new
      reader.page(page).walk(receiver)
      receiver.content
    end

end
