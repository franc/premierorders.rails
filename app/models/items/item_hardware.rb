require 'property.rb'

class ItemHardware < ItemComponent
  HEIGHT_QTY = PropertyDescriptor.new(:quantity_by_height, [], [Property::Height])
  WIDTH_QTY  = PropertyDescriptor.new(:quantity_by_width,  [], [Property::Width])
  DEPTH_QTY  = PropertyDescriptor.new(:quantity_by_depth,  [], [Property::Depth])

  def self.component_types
    [Item]
  end

  def self.optional_properties
    [HEIGHT_QTY, WIDTH_QTY, DEPTH_QTY]
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

  def cost_expr(units, color, contexts)
    qty_expr = if h_qty(units).empty? && w_qty(units).empty? && d_qty(units).empty?
      term(quantity)
    else
      quantities = [
        h_qty(units).map{|f| mult(H, term(f))}, 
        w_qty(units).map{|f| mult(W, term(f))}, 
        d_qty(units).map{|f| mult(D, term(f))}
      ]

      qty_exprs = quantities.inject([]) {|a, v| v.map{|expr| a << expr}.orSome(a)}
      sum(*qty_exprs)
    end

    component.cost_expr(units, color, contexts).map{|e| mult(qty_expr, e)}
  end
end
