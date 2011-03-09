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

  def cost_expr(units, color, contexts)
    component.cost_expr(units, color, contexts).map do |component_cost|
      width_factor.map{|f| component_cost.replace(W, mult(W, term(f)))}.orSome(component_cost)
    end
  end
end
