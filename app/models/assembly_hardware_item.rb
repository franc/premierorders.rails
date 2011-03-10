require 'fp'

class AssemblyHardwareItem
  attr_reader :item, :quantity, :total_price, :errors

  def initialize(item, quantity = 0, total_price = BigDecimal.new("0.0"))
    @item = item
    @errors = []
    @quantity = quantity
    @total_price = total_price
  end

  def add_hardware(job_item_component, job_item_qty)
    raise "Item mismatch: #{@item} is not equal to #{job_item_component.item}" unless @item == job_item_component.item
    component_quantity = job_item_component.quantity.cata(
      lambda {|err| errors << err; 0},
      lambda {|qty| qty}
    )

    @quantity += (component_quantity * job_item_qty)
    @total_price += job_item_component.unit_price.cata(
      lambda {|err| errors << err; 0},
      lambda {|price| price * (component_quantity * job_item_qty)}
    )
  end

  def +(other)
    raise "Item mismatch: #{@item} is not equal to #{other.item}" unless @item == other.item
    AssemblyHardwareItem.new(@item, @quantity + other.quantity, @total_price + other.total_price)
  end

  def *(qty)
    @quantity *= qty
    @total_price *= qty
  end

  def tracking_id
    ''
  end

  def item_name
    @item.name
  end

  def color
    Option.none
  end

  def width
    # The relationships between the dimensions of items need to be factored out of the 
    # pricing expressions to be able to have meaningful values here.
    Option.none
  end

  def height
    Option.none
  end

  def depth
    Option.none
  end

  def unit_price
    @total_price / @quantity
  end

  alias_method :net_unit_price, :unit_price
  alias_method :computed_unit_price, :unit_price

  def net_total
    @total_price
  end

  def unit_price_mismatch
    None::NONE
  end

  def unit_weight
    nil
  end

  def install_cost
    Option.new(item.install_cost).map do |w|
      Either.right(w * @quantity)
    end
  end

  def comment
    ''
  end
end
