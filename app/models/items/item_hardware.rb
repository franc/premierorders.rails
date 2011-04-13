require 'property'
require 'properties'

class Items::ItemHardware < ItemComponent
  HEIGHT_QTY = Properties::PropertyDescriptor.new(:quantity_by_height, [], [Property::Height])
  WIDTH_QTY  = Properties::PropertyDescriptor.new(:quantity_by_width,  [], [Property::Width])
  DEPTH_QTY  = Properties::PropertyDescriptor.new(:quantity_by_depth,  [], [Property::Depth])
  RANGED_QTY = Properties::PropertyDescriptor.new(:qty_by_range, [], [Property::RangedValue])

  def self.component_types
    [Item]
  end

  def self.optional_properties
    [HEIGHT_QTY, WIDTH_QTY, DEPTH_QTY, RANGED_QTY]
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

  def r_qtys
    properties.find_all_by_descriptor(RANGED_QTY).map{|v| v.property_values}.flatten
  end

  def qty_expr(query_context)
    units = query_context.units
    if h_qty(units).empty? && w_qty(units).empty? && d_qty(units).empty? && r_qtys.empty?
      term(quantity)
    else
      quantities = [
        h_qty(units).map{|f| mult(H, term(f))}, 
        w_qty(units).map{|f| mult(W, term(f))}, 
        d_qty(units).map{|f| mult(D, term(f))}
      ] 

      qty_exprs = quantities.inject([]){|a, v| v.map{|expr| a << expr}.orSome(a)} + r_qtys.map{|v| v.expr(units)}
      sum(*qty_exprs)
    end
  end
end
