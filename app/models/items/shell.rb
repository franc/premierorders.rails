class Shell < Item
  # Computes the price for a job item where the associated item is an instance of Shell
  def calculate_price(width, height, depth, color, units )
    item_components.inject(0.0) do |total, component_conf|
      total + component_conf.calculate_price(width, height, depth, color, units)
    end
  end
end

class ShellBackPanel < ItemComponent
  def calculate_price(width, height, depth, color, units )
    puts "Calculating back panel price"
    quantity * component.calculate_price(height, width, color, units)
  end
end

class ShellTopPanel < ItemComponent
  EB_SIDES = [:left, :right, :rear, :front]
  def self.optional_properties
    PropertyDescriptor.new(:edge_band, EB_SIDES, [EdgeBand])
  end

  def calculate_price(width, height, depth, color, units )
    edge_banding = EB_SIDES.inject({}) do |result, side|
      properties.find_all_by_family_with_qualifier(:edge_band, side).each do |prop|
        result[side] = prop.property_values.map{|p| prop.hydrate(p)}.find do |v|
          v.color == color
        end
      end

      result
    end

    eb_l = edge_banding[:left]  ? edge_banding[:left].price(depth, units)  : 0.0
    eb_r = edge_banding[:right] ? edge_banding[:right].price(depth, units) : 0.0
    eb_b = edge_banding[:rear]  ? edge_banding[:rear].price(width, units)  : 0.0
    eb_f = edge_banding[:front] ? edge_banding[:front].price(width, units) : 0.0

    edgeband_price = eb_l + eb_r + eb_b + eb_f

    puts "edgeband price: #{edgeband_price}"
    quantity * (component.calculate_price(width, depth, color, units) + edgeband_price)
  end
end

class ShellBottomPanel < ItemComponent
  def calculate_price(width, height, depth, color, units )
    quantity * component.calculate_price(width, depth, color, units)
  end
end

class ShellSidePanel < ItemComponent
  def calculate_price(width, height, depth, color, units )
    quantity * component.calculate_price(height, depth, color, units)
  end
end
