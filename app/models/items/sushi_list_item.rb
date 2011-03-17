require 'properties'
require 'fp'

class Items::SushiListItem < Item
  AREA = Properties::PropertyDescriptor.new(:area, [], [Property::Area])
  EDGE_BANDING = Properties::PropertyDescriptor.new(:edge_band, [], [Property::EdgeBand])

  def self.component_association_types
    {:required => [Items::SushiItemChoice]}
  end

  def self.optional_properties
    [AREA, Items::Panel::MATERIAL, EDGE_BANDING]
  end

  def area
    @area ||= properties.find_value(AREA)
    @area
  end

  def cutrite_id
    local = read_attribute(:cutrite_id)
    local.nil? && !components.empty? ? components[0].cutrite_id : local
  end

  def purchase_part_id
    local = read_attribute(:purchase_part_id)
    local.nil? && !components.empty? ? components[0].purchase_part_id : local
  end

  def width(units = :in)
    area.map{|v| v.width(units)}
  end

  def height(units = :in)
    area.map{|v| v.length(units)}
  end

  def depth(units = :in)
    None::NONE
  end

  def dvinci_color_code
    properties.find_value(EDGE_BANDING).mapn{|v| v.dvinci_id}.orElseLazy do
      properties.find_value(Items::Panel::MATERIAL).mapn{|v| v.dvinci_id}
    end
  end

  # Override rebated cost expression; no rebate on sushi list items.
  def rebated_cost_expr(units, color, contexts)
    cost_expr(units, color, contexts)
  end

  def cost_expr(units, color, contexts)
    use_color = Option.new(color).orElse(dvinci_color_code).orSome(nil)
    base_expr = super(units, use_color, contexts)
    base_expr.map do |expr|
      area.map{|v| v.replace_variables(expr, units)}.orSome(expr)
    end
  end
end
