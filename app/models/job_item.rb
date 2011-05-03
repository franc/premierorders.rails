require 'expressions'
require 'properties'
require 'item_queries'
require 'fp'

class JobItem < ActiveRecord::Base
  include Expressions

	belongs_to :job
  belongs_to :item
  belongs_to :production_batch
	has_many   :job_item_properties, :dependent => :destroy, :extend => Properties::Association
  has_many   :job_item_components, :dependent => :destroy

  def dimensions_property 
    @dimensions_property ||= Option.new(job_item_properties.find_by_family(:dimensions))
    @dimensions_property
  end

  def purchasing_type?(*types)
    types.any? do |type|
      item_purchasing.casecmp(type) == 0 || 
      (ingest_id && ingest_id.strip[-1,1].casecmp(type[0...1]) == 0)
    end
  end

  def item_sort_group?(sort_group) 
    cat = ItemCategory.find_by_sort_group(sort_group)
    cat && item && item.category == cat.category
  end

  def production_batch_closed?
    production_batch && production_batch.closed?
  end

  def inventory?
    purchasing_type?('Inventory')
  end

  def buyout?
    purchasing_type?('Buyout')
  end

  def ship_by?(*types)
    types.any? do |type|
      item && item.ship_by && item.ship_by.casecmp(type) == 0
    end
  end

  def width(units = :in)
    dimensions_property.bind {|p| Option.call(:width, p, units)}.orElseLazy do
      item && item.respond_to?(:width) ? item.width(units) : None::NONE
    end
  end

  def height(units = :in)
    dimensions_property.bind {|p| Option.call(:height, p, units)}.orElseLazy do
      item && item.respond_to?(:height) ? item.height(units) : None::NONE
    end
  end

  def depth(units = :in)
    dimensions_property.bind {|p| Option.call(:depth, p, units)}.orElseLazy do
      item && item.respond_to?(:depth) ? item.depth(units) : None::NONE
    end
  end

  def color
    Option.new(job_item_properties.find_by_family(:color)).map{|p| p.color}.orElseLazy do
      Option.iif(item && item.respond_to?(:color)) do
        item.color
      end
    end
  end

  def dvinci_color_code
    id_parser = /(\w{3})\.(\w{3})\.(\w{3})\.(\w{3})\.(\d{2})(\w)/
    Option.new(ingest_id).map{|iid| iid.match(id_parser).captures[3]}.orElseLazy do
      Option.iif(item && item.respond_to?(:dvinci_color_code)) do
        item.dvinci_color_code
      end
    end
  end

  def item_name
    item.nil? ? "#{ingest_desc}: #{ingest_id}" : item.name
  end

  def item_purchasing
    (item.nil? || item.purchasing.nil?) ? "(unavailable)" : item.purchasing
  end

  def inventory_hardware
    @inventory_hardware ||= job_item_components.inject({}) do |m, job_item_component|
      m[job_item_component.item] ||= AssemblyHardwareItem.new(job_item_component.item)
      m[job_item_component.item].add_hardware(job_item_component, quantity)
      m
    end
      
    @inventory_hardware
  end

  def unit_price_mismatch
    if self.computed_unit_price && self.unit_price
      difference(self.computed_unit_price, self.unit_price)
    else
      None::NONE
    end
  end

  def net_unit_price
    if pricing_cache_status.nil?
      update_cached_values
      self.save
    end
    
    case pricing_cache_status.to_sym
      when :ok            then computed_unit_price - unit_hardware_cost
      when :error         then 0
      when :not_computed  then (unit_price.nil? || item.nil?) ? 0 : unit_price - unit_hardware_cost
    end
  end

  def net_total
    net_unit_price * (quantity || 0)
  end

  def hardware_total
    unit_hardware_cost * (quantity || 0)
  end

  # The following price attributes are used for display:
  # computed_unit_price
  # unit_price from import (for mismatch checking)
  # weight
  # hardware_cost
  def update_cached_values(units = :in)
    self.cache_calculation_units = units.to_s

    # hardware components of the associated item are queried in a non-bulk context
    cache_inventory_hardware_components(
      ItemQueries::QueryContext.new(
        :units => units, 
        :color => color.orSome(nil)
      )
    )

    # directly purchased hardware is queried in a bulk context
    price_query_context = ItemQueries::QueryContext.new(
      :units => units, 
      :color => color.orSome(nil),
      :bulk  => job.source == 'catalog' && item && item.kind_of?(Items::BulkItem) 
    )

    cup = compute_unit_price(price_query_context)
    self.computed_unit_price = cup.bind{|r| r.right.toOption}.orSome(nil)
    self.pricing_cache_status = cup.cata(
      lambda {|r| r.cata(
        lambda {|err| :error},
        lambda {|ok| :ok}
      )},
      :not_computed
    )

    self.unit_hardware_cost = compute_hardware_cost
    self.unit_install_cost = compute_install_cost(price_query_context).bind{|r| r.right.toOption}.orSome(nil)
    self.unit_weight = compute_weight(price_query_context).bind{|r| r.right.toOption}.orSome(nil)
  end

  def compute_unit_price(query_context)
    computed_unit_price = Option.new(item).bind do |i|
      begin
        i.wholesale_price_expr(query_context).map {|expr| dimension_eval(expr)}
      rescue
        logger.error "Error computing unit price: #{$!.message}\n #{$!.backtrace.join("\n")}"
        Option.some(Either.left($!.message))
      end
    end

    computed_unit_price
  end

  def compute_hardware_cost
    job_item_components.inject(BigDecimal.new("0.00")) do |total, i| 
      total + (i.unit_price.right.bind{|p| i.quantity.right.map{|q| p * q}}.right.orElse(0))
    end
  end

  def compute_install_cost(query_context)
    Option.new(item).bind do |i|
      begin
        i.install_cost_expr(query_context).map {|expr| dimension_eval(expr)}
      rescue
        logger.error "Error computing install cost: #{$!.message}\n #{$!.backtrace.join("\n")}"
        Option.some(Either.left($!.message))
      end
    end
  end

  def compute_weight(query_context)
    Option.new(item).bind do |i|
      begin
        i.weight_expr(query_context).map {|expr| dimension_eval(expr)}
      rescue
        logger.error "Error computing weight: #{$!.message}\n #{$!.backtrace.join("\n")}"
        Option.some(Either.left($!.message))
      end
    end
  end

  private

  def difference(computed, imported)
    Option.some((computed.round(2) - imported.round(2)).abs).filter do |diff|
      diff / imported > 0.005
    end
  end

  PRICING_STATES = [
    :not_computed,
    :error,
    :ok
  ]

  def cache_inventory_hardware_components(query_context)
    hardware_query = ItemQueries::HardwareQuery.new do |i|
      i.purchasing == 'Inventory'
    end

    if item
      job_item_components.clear
      item.query(hardware_query, query_context).each do |item_hardware| 
        # There is a bug here. Since the expression for the quantity expression may be derived
        # from a deep traversal of the assembly tree, and since the traversal of the assembly tree
        # may result in a function being applied to a dimension variable along the way, that function
        # will not have been applied to the dimension value used by dimension_eval. In order to
        # represent this correctly, it would be necessary to add a degree of laziness to the expression
        # generation process such that in the generation of the AST, any association that applies
        # a function to a dimension variable of the contained components composes that function and
        # passes it downward so that it may be applied to the dimension variable at the lowest level. 
        # Too complicated to tackle just now.

        component = self.job_item_components.create(:item => item_hardware.component)
        dimension_eval(item_hardware.qty_expr(query_context)).cata(
          lambda {|err| component.qty_calc_err = err},
          lambda {|qty| component.quantity = qty}
        )

        item_hardware.component.cost_expr(query_context).each do |expr|
          dimension_eval(expr).cata(
            lambda{|err|  component.cost_calc_err = err},
            lambda{|cost| component.unit_cost = cost}
          )
        end
        component.save
      end
    end
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
