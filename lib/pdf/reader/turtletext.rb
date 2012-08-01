# Class for reading structured text content
#
# Typical usage:
#
#   reader = PDF::Reader::Turtletext.new(pdf_filename)
#   page = 1
#   heading_position = reader.text_position(/transaction table/i)
#   next_section = reader.text_position(/transaction summary/i)
#   transaction_rows = reader.text_in_region(
#     heading_position[x], 900,
#     heading_position[y] + 1,next_section[:y] -1
#   )
#
class PDF::Reader::Turtletext
  attr_reader :reader
  attr_reader :options

  # +source+ is a file name or stream-like object
  # Supported +options+ include:
  # * :y_precision
  def initialize(source, options={})
    @options = options
    @reader = PDF::Reader.new(source)
  end

  # Returns the precision required in y positions.
  # This is the fuzz range for interpreting y positions.
  # Lines with y positions +/- +y_precision+ will be merged together.
  # This helps align text correctly which may visually appear on the same line, but is actually
  # off by a few pixels.
  def y_precision
    options[:y_precision] ||= 3
  end

  # Returns positional (with fuzzed y positioning) text content collection as a hash:
  #   [ fuzzed_y_position, [[x_position,content]] ]
  def content(page=1)
    @content ||= []
    if @content[page]
      @content[page]
    else
      @content[page] = fuzzed_y(precise_content(page))
    end
  end

  # Returns an Array with fuzzed positioning, ordered by decreasing y position. Row content order by x position.
  #   [ fuzzed_y_position, [[x_position,content]] ]
  # Given +input+ as a hash:
  #   { y_position: { x_position: content}}
  # Fuzz factors: +y_precision+
  def fuzzed_y(input)
    output = []
    input.keys.sort.reverse.each do |precise_y|
      matching_y = output.map(&:first).select{|new_y| (new_y - precise_y).abs < y_precision }.first || precise_y
      y_index = output.index{|y| y.first == matching_y }
      new_row_content = input[precise_y].to_a
      if y_index
        row_content = output[y_index].last
        row_content += new_row_content
        output[y_index] = [matching_y,row_content.sort{|a,b| a.first <=> b.first }]
      else
        output << [matching_y,new_row_content.sort{|a,b| a.first <=> b.first }]
      end
    end
    output
  end

  # Returns positional text content collection as a hash with precise x,y positioning:
  #   { y_position: { x_position: content}}
  def precise_content(page=1)
    @precise_content ||= []
    if @precise_content[page]
      @precise_content[page]
    else
      @precise_content[page] = load_content(page)
    end
  end

  # Returns an array of text elements found within the x,y limits:
  # * x ranges from +xmin+ (left of page) to +xmax+ (right of page)
  # * y ranges from +ymin+ (bottom of page) to +ymax+ (top of page)
  # Each line of text is an array of the seperate text elements found on that line.
  #   [["first line first text", "first line last text"],["second line text"]]
  def text_in_region(xmin,xmax,ymin,ymax,page=1)
    return [] unless xmin && xmax && ymin && ymax
    text_map = content(page)
    box = []

    text_map.each do |y,text_row|
      if y >= ymin && y<= ymax
        row = []
        text_row.each do |x,element|
          if x >= xmin && x<= xmax
            row << element
          end
        end
        box << row unless row.empty?
      end
    end
    box
  end

  # Returns the position of +text+ on +page+
  #   {x: val, y: val }
  # +text+ may be a string (exact match required) or a Regexp.
  # Returns nil if the text cannot be found.
  def text_position(text,page=1)
    item = if text.class <= Regexp
      content(page).map do |k,v|
        if x = v.reduce(nil){|memo,vv|  memo = (vv[1] =~ text) ? vv[0] : memo  }
          [k,x]
        end
      end
    else
      content(page).map {|k,v| if x = v.rassoc(text) ; [k,x] ; end }
    end
    item = item.compact.flatten
    unless item.empty?
      { :x => item[1], :y => item[0] }
    end
  end

  # Returns a text region definition using a descriptive block.
  #
  # Usage:
  #
  #   textangle = reader.bounding_box do
  #     page 1
  #     below /electricity/i
  #     above 10
  #     right_of 240.0
  #     left_of "Total ($)"
  #   end
  #   textangle.text
  #
  # Alternatively, an explicit block parameter may be used:
  #
  #   textangle = reader.bounding_box do |r|
  #     r.page 1
  #     r.below /electricity/i
  #     r.above 10
  #     r.right_of 240.0
  #     r.left_of "Total ($)"
  #   end
  #   textangle.text
  #   => [['string','string'],['string']] # array of rows, each row is an array of column text element
  #
  def bounding_box(&block)
    PDF::Reader::Turtletext::Textangle.new(self,&block)
  end

  private

    def load_content(page)
      receiver = PDF::Reader::PositionalTextReceiver.new
      reader.page(page).walk(receiver)
      receiver.content
    end

end
