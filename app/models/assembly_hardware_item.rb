class AssemblyHardwareItem
  def initialize(job_item, item_hardware)
    @job_item = job_item
    @item_hardware = item_hardware
  end

  def tracking_id
    ''
  end

  def item
    @item_hardware.component
  end

  def item_name
    item.name
  end

  def color
    @job_item.color
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

  def quantity
    @job_item.dimension_eval(@item_hardware.qty_expr(:in, color.orSome(nil)))
  end

  def compute_unit_price
    @item_hardware.unit_cost_expr(:in, color.orSome(nil), []).map do |expr| 
      @job_item.dimension_eval(expr)
    end
  end

  def unit_price
    # This is wrong, but it requires rework of the display to correct it. So this is a hack
    # to allow continued reuse of jobs/_items_table.html.erb
    compute_unit_price.orSome(0.0)
  end

  def compute_total
    @item_hardware.cost_expr(:in, color.orSome(nil), []).map do |expr| 
      @job_item.dimension_eval(expr)
    end
  end

  def comment
    ''
  end
end
