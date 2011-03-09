require 'properties'

module Items::CornerCabinetPanelAssociation
  include Items::PanelEdgePricing, Items::Margins
  CORNER_SIDE_RATIO = Properties::PropertyDescriptor.new(:corner_cab_side_ratio, [], [Property::ScalingFactor])

  def corner_side_ratio
    properties.find_value(CORNER_SIDE_RATIO).map{|v| v.factor}.orLazy do
      raise "Ratio of wall side to side must be specified for corner cabinet panel #{self.inspect}"
    end
  end

  def front_width_expr
    mult(sub(D, side_width_expr), term(Math.sqrt(2)))
  end

  def side_width_expr
    mult(D, term(corner_side_ratio))
  end
end

