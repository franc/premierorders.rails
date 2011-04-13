require 'expressions'
require 'fp'

module Items::PanelEdgePricing
  include Expressions

  def edge_materials(sides, color)
    sides.inject({}) do |result, side|
      properties.find_by_family_with_qualifier(:edge_band, side).each do |prop|
        mvalues = prop.property_values.all
        material = if mvalues.empty?
          raise "Could not determine material values from #{prop}"
        elsif color && mvalues.length > 1 
          prop.property_values.detect do |v| 
            (v.respond_to?(:dvinci_id) && v.dvinci_id.strip == color.strip) || v.color.strip.casecmp(color.strip) == 0
          end 
        else 
          mvalues[0]
        end

        raise "Could not determine material values for #{color} from #{mvalues}" if material.nil?
        result[side] = material 
      end

      result
    end
  end

  def edgeband_cost_expr(dimension_vars, units, color)
    exprs = []
    edge_materials(dimension_vars.keys, color).each do |side, banding|
      exprs << banding.cost_expr(units, dimension_vars[side])
    end
    exprs.empty? ? Option.none() : Option.some(sum(*exprs))
  end
end

