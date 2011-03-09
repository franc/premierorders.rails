class Items::ColorOption
  attr_reader :dvinci_id, :color
  def initialize(dvinci_id, color)
    @dvinci_id = dvinci_id
    @color = color
  end

  def eql?(other)
    dvinci_id.eql?(other.dvinci_id) && color.eql?(other.color)
  end

  alias_method :==, :eql?
end


