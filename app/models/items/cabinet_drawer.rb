require 'properties'
require 'fp'

class Items::CabinetDrawer < ItemComponent
  WIDTH_FACTOR = Properties::PropertyDescriptor.new(:factor, [:width], [Property::ScalingFactor])

  def self.optional_properties
    [WIDTH_FACTOR]  
  end

  def self.component_types
    [Items::Drawer]
  end

  def width_factor
    Option.new(properties.find_by_descriptor(WIDTH_FACTOR)).map{|p| p.property_values.first.factor}
  end

  def cost_expr(query_context)
    rewrite_component_expr(component.cost_expr(query_context))
  end

  def weight_expr(query_context)
    rewrite_component_expr(component.weight_expr(query_context))
  end

  def rewrite_component_expr(expr_option)
    expr_option.map do |component_expr|
      width_factor.map{|f| component_expr.replace(W, mult(W, term(f)))}.orSome(component_expr)
    end
  end
end
