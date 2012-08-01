# A DSL syntax for text extraction.
#
# textangle = PDF::Reader::Turtletext::Textangle.new(reader) do |r|
#   r.page = 1
#   r.below = "Electricity Services"
#   r.above = "Gas Services by City Gas Pte Ltd"
#   r.right_of = 240.0
#   r.left_of = "Total ($)"
# end
# textangle.text
#
class PDF::Reader::Turtletext::Textangle
  attr_reader :reader
  attr_accessor :page
  attr_writer :above,:below,:left_of,:right_of

  # +turtletext_reader+ is a PDF::Reader::Turtletext
  def initialize(turtletext_reader,&block)
    @reader = turtletext_reader
    @page = 1
    if block_given?
      if block.arity == 1
        yield self
      else
        instance_eval &block
      end
    end
  end

  def above(*args)
    if value = args.first
      @above = value
    end
    @above
  end

  def below(*args)
    if value = args.first
      @below = value
    end
    @below
  end

  def left_of(*args)
    if value = args.first
      @left_of = value
    end
    @left_of
  end

  def right_of(*args)
    if value = args.first
      @right_of = value
    end
    @right_of
  end

  # Returns the text
  def text
    return unless reader

    xmin = if right_of
      if [Fixnum,Float].include?(right_of.class)
        right_of
      elsif xy = reader.text_position(right_of,page)
        xy[:x] + 1
      end
    else
      0
    end
    xmax = if left_of
      if [Fixnum,Float].include?(left_of.class)
        left_of
      elsif xy = reader.text_position(left_of,page)
        xy[:x] - 1
      end
    else
      99999 # TODO actual limit
    end

    ymin = if above
      if [Fixnum,Float].include?(above.class)
        above
      elsif xy = reader.text_position(above,page)
        xy[:y] + 1
      end
    else
      0
    end
    ymax = if below
      if [Fixnum,Float].include?(below.class)
        below
      elsif xy = reader.text_position(below,page)
        xy[:y] - 1
      end
    else
      99999 # TODO actual limit
    end

    reader.text_in_region(xmin,xmax,ymin,ymax,page)
  end

end
