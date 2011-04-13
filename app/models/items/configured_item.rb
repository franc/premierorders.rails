require 'properties'
require 'fp'

class Items::ConfiguredItem < Item
  AREA = Properties::PropertyDescriptor.new(:area, [], [Property::Area])
  EDGE_BANDING = Properties::PropertyDescriptor.new(:edge_band, [], [Property::EdgeBand])

  def self.component_association_types
    {:required => [Items::ConfiguredComponent]}
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

  # Returns an Option containing any color code that can be determined from the
  # edge banding or materials.
  def dvinci_color_code
    properties.find_value(EDGE_BANDING).mapn{|v| v.dvinci_id}.orElseLazy do
      properties.find_value(Items::Panel::MATERIAL).mapn{|v| v.dvinci_id}
    end
  end

  # Override rebated cost expression; no rebate on sushi list items.
  def rebated_cost_expr(query_context)
    cost_expr(query_context)
  end

  def cost_expr(query_context)
    ctx = query_context.left_merge(dvinci_color_code.to_m(:color))
    super(ctx).map do |expr|
      area.map{|v| v.replace_variables(expr, ctx.units)}.orSome(expr)
    end
  end

  def weight_expr(query_context)
    ctx = query_context.left_merge(dvinci_color_code.to_m(:color))
    super(ctx).map do |expr|
      area.map{|v| v.replace_variables(expr, ctx.units)}.orSome(expr)
    end
  end
end
