require 'property.rb'

class ItemHardware < ItemComponent
  HEIGHT_QTY = PropertyDescriptor.new(:quantity_by_height, [], [Property::Height])
  WIDTH_QTY = PropertyDescriptor.new(:quantity_by_width, [], [Property::Width])
  DEPTH_QTY = PropertyDescriptor.new(:quantity_by_depth, [], [Property::Depth])

  def self.component_types
    [Item]
  end

  def self.optional_properties
    [HEIGHT_QTY,WIDTH_QTY,DEPTH_QTY]
  end

  def h_qty(units) 
    properties.find_value(HEIGHT_QTY).map{|p| p.height(units)}
  end

  def w_qty(units) 
    properties.find_value(WIDTH_QTY).map{|p| p.width(units)}
  end

  def d_qty(units) 
    properties.find_value(DEPTH_QTY).map{|p| p.depth(units)}
  end

  def calculate_price(width, height, depth, units, color)
    qty = if h_qty(units).empty? && w_qty(units).empty? && d_qty(units).empty?
      quantity
    else
      h_qty(units).map{|f| (height / f).floor + 1}.orSome(0) + 
      w_qty(units).map{|f| (width / f).floor + 1}.orSome(0) + 
      d_qty(units).map{|f| (depth / f).floor + 1}.orSome(0)
    end 

    component.calulate_price(width, height, depth, units, color) * qty
  end

  def pricing_expr(units, color)
    qty_expr = if h_qty(units).empty? && w_qty(units).empty? && d_qty(units).empty?
      quantity
    else
      quantities = [h_qty(units).map{|f| "(H * #{f})"}, w_qty(units).map{|f| "(W * #{f})"}, d_qty(units).map{|f| "(D * #{f})"}].inject([]) do |a, v| 
        v.map{|expr| a << "#{expr}"}.orSome(a)
      end

      "(#{quantities.join(" + ")})"
    end

    "(#{component.pricing_expr(units, color)} * #{qty_expr})"
  end
end
