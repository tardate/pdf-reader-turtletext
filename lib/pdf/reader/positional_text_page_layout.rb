class PDF::Reader::PositionalTextPageLayout < PDF::Reader::PageLayout

  def to_pos_hash
    pos_hash = {}
    @runs.each do |run|
      pos_hash[run.y] ||= {}
      pos_hash[run.y][run.x] ||= ''
      pos_hash[run.y][run.x] << run.text
    end
    pos_hash
  end

end