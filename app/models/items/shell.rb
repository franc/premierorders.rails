class Shell < Item
  # Computes the price for a job item where the associated item is an instance of Shell
  def calculate_price(width, height, depth, color)
    item_total = item_components.inject(0.0) do |total, component_conf|
      total + component_conf.calculate_price(width, height, depth, color)
    end

    item_total * job_item.quantity
  end
end

class ShellTopPanel < ItemComponent
  def calculate_price(width, height, depth, color)
    quantity * component.calculate_price(width, depth, color, edge_banding)
  end
end

class ShellBottomPanel < ItemComponent
  def calculate_price(width, height, depth, color)
    quantity * component.calculate_price(width, depth, color, edge_banding)
  end
end

class ShellSidePanel < ItemComponent
  def calculate_price(width, height, depth, color)
    quantity * component.calculate_price(height, depth, color, edge_banding)
  end
end
