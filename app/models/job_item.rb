require 'util/option'
require 'util/either'
require 'expressions'

class JobItem < ActiveRecord::Base
  include Expressions

	belongs_to :job
  belongs_to :item
  belongs_to :production_batch
	has_many   :job_item_properties, :dependent => :destroy, :extend => Properties::Association

  def dimensions_property 
    @dimensions_property ||= Option.new(job_item_properties.find_by_family(:dimensions))
    @dimensions_property
  end

  def purchasing_type?(*types)
    types.any? do |type|
      item_purchasing.casecmp(type) == 0 || 
      ingest_id.strip[-1,1].casecmp(type[0...1]) == 0
    end
  end

  def inventory?
    purchasing_type?('Inventory')
  end

  def buyout?
    purchasing_type?('Buyout')
  end

  def width(units = :in)
    dimensions_property.bind do |p|
      Option.call(:width, p, units)
    end
  end

  def height(units = :in)
    dimensions_property.bind do |p|
      Option.call(:height, p, units)
    end
  end

  def depth(units = :in)
    dimensions_property.bind do |p|
      Option.call(:depth, p, units)
    end
  end

  def color
    Option.new(job_item_properties.find_by_family(:color)).map{|p| p.color}
  end

  def dvinci_color_code
    ingest_id.match(/(\w{3})\.(\w{3})\.(\w{3})\.(\w{3})\.(\d{2})(\w)/).captures[3]
  end

  def item_name
    item.nil? ? "#{ingest_desc}: #{ingest_id}" : item.name
  end

  def item_purchasing
    item.nil? ? "(unavailable)" : item.purchasing
  end

  def inventory_hardware
    hardware_query = HardwareQuery.new do |i|
      i.purchasing == 'Inventory'
    end

    @inventory_hardware ||= Option.new(item).inject({}) do |mm, i| 
      i.query(hardware_query, []).inject(mm) do |mmm, item_hardware| 
        mmm[item_hardware.component] ||= AssemblyHardwareItem.new(item_hardware.component)
        mmm[item_hardware.component].add_hardware(self, item_hardware)
        mmm
      end
    end

    @inventory_hardware
  end

  def weight(units = :in)
    Option.new(item).bind do |i|
      begin
        i.weight_expr(units, []).map {|expr| dimension_eval(expr)}
      rescue
        Option.some(Either.left($!.message))
      end
    end
  end

  def install_cost(units = :in)
    Option.new(item).bind do |i|
      begin
        i.install_cost_expr(units, []).map {|expr| dimension_eval(expr)}
      rescue
        Option.some(Either.left($!.message))
      end
    end
  end

  def hardware_cost
    inventory_hardware.values.inject(BigDecimal.new("0.00")) {|total, i| total + i.total_price}
  end

  def compute_unit_price(units = :in)
    Option.new(item).bind do |i|
      begin
        i.rebated_cost_expr(units, color.orSome(nil), []).map {|expr| dimension_eval(expr)}
      rescue
        logger.error "Error computing unit price: #{$!.message}\n #{$!.backtrace.join("\n")}"
        Option.some(Either.left($!.message))
      end
    end
  end

  def compute_total(units = :in)
    compute_unit_price(units).map{|e| e.right.map{|t| t * quantity}}
  end

  def net_unit_price(units = :in)
    compute_unit_price(units).bind{|p| p.right.toOption.map{|v| v - hardware_cost}}.orSome(unit_price)
  end

  def net_total(units = :in)
    net_unit_price(units) * quantity
  end

  def dimension_eval(expr)
    vars = {ZERO => BigDecimal.new("0.00")}.merge(width.to_h(W)).merge(height.to_h(H)).merge(depth.to_h(D))
    begin
      Either.right(expr.evaluate(vars))
    rescue
      logger.error("Unable to evaluate expression (#{expr}) at #{vars.inspect}: \n#{$!.message}")
      Either.left("Unable to evaluate expression (#{expr}) at #{vars.inspect}")
    end
  end
end
