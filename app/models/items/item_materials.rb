require 'util/option.rb'

module ItemMaterials
  # retrieve the material property values by color.
  def material(descriptor, color)
    mprop = properties.find_by_descriptor(descriptor)
    mvalues = mprop.property_values.all
    raise "Could not determine material values from #{mprop}" if mvalues.empty?
    mval = mvalues.length > 1 ? mvalues.detect{|v| color.strip == v.dvinci_id.strip || v.color.strip.casecmp(color.strip) == 0} : mvalues[0]
    raise "Could not determine material values for #{color} from #{mvalues}" if mval.nil?
    mval
  end

  def color_options(descriptor = material_descriptor)
    Option.new(properties.find_by_descriptor(descriptor)).map{|p| p.property_values.inject([]) {|m, v| m << v.color}}.orSome([])
  end
end

module PanelEdgePricing
  include Expressions

  def edge_materials(sides, color)
    sides.inject({}) do |result, side|
      properties.find_by_family_with_qualifier(:edge_band, side).each do |prop|
        mvalues = prop.property_values.all
        raise "Could not determine material values from #{prop}" if mvalues.empty?
        material = mvalues.length > 1 ? prop.property_values.detect{|v| color.strip == v.dvinci_id.strip || v.color.strip.casecmp(color.strip) == 0} : mvalues[0]
        raise "Could not determine material values for #{color} from #{mvalues}" if material.nil?
        result[side] = material unless material.nil?
      end

      result
    end
  end

  def edgeband_cost_expr(dimension_vars, units, color)
    exprs = []
    edge_materials(dimension_vars.keys, color).each do |side, banding|
      exprs << banding.pricing_expr(units, dimension_vars[side])
    end
    exprs.empty? ? Option.none() : Option.some(sum(exprs))
  end
end
