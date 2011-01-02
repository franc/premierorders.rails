require 'util/option.rb'

module ItemMaterials
  # retrieve the material property values by color.
  def material(descriptor, color)
    mprop = properties.find_by_descriptor(descriptor)
    mvalues = mprop.property_values.all
    raise "Could not determine material values from #{mprop}" if mvalues.empty?
    mval = mvalues.length > 1 ? mvalues.detect{|v| v.color.strip.casecmp(color.strip) == 0} : mvalues[0]
    raise "Could not determine material values for #{color} from #{mvalues}" if mval.nil?
    mval
  end

  def color_options
    Option.new(properties.find_by_descriptor(material_descriptor)).map{|p| p.property_values.inject([]) {|m, v| m << v.color}}.orSome([])
  end
end

module PanelEdgePricing
  def edge_materials(sides, color)
    sides.inject({}) do |result, side|
      properties.find_by_family_with_qualifier(:edge_band, side).each do |prop|
        material = prop.property_values.detect{|v| v.color.strip.casecmp(color.strip) == 0}
        result[side] = material unless material.nil?
      end

      result
    end
  end

  def edge_banding_price(color, side_lengths, units)
    # Find the edge banding property value for each side
    edge_banding = edge_materials(side_lengths.keys, color)

    total = 0.0
    side_lengths.each do |side, length|
      total += edge_banding[side].calculate_price(length, units) if edge_banding[side]
    end
    total
  end

  def edge_banding_pricing_expr(dimension_vars, units, color)
    exprs = []
    edge_materials(dimension_vars.keys, color).each do |side, banding|
      exprs << banding.pricing_expr(units, dimension_vars[side])
    end

    "(#{exprs.join(" + ")})"
  end
end

module PanelMargins
  MARGIN = PropertyDescriptor.new(:margin, [], [Property::Margin])

  def margin_factor
    properties.find_value(MARGIN)
  end

  def apply_margin(base_expr)
    margin_factor.map{|f| "(#{base_expr} / #{f.factor})"}.orSome(base_expr)
  end
end


