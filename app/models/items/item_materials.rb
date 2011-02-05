require 'util/option.rb'

class ColorOption
  attr_reader :dvinci_id, :color
  def initialize(dvinci_id, color)
    @dvinci_id = dvinci_id
    @color = color
  end

  def eql?(other)
    dvinci_id.eql?(other.dvinci_id) && color.eql?(other.color)
  end

  alias_method :==, :eql?
end

module ItemMaterials
  # retrieve the material property values by color.
  def material(descriptor, color)
    mprop = properties.find_by_descriptor(descriptor)
    mvalues = mprop.property_values.all
    mval = if mvalues.empty?
      raise "Could not determine material values from #{mprop}" 
    elsif mvalues.length > 1 
      mvalues.detect do |v| 
        (v.respond_to?(:dvinci_id) && v.dvinci_id.strip == color.strip) || v.color.strip.casecmp(color.strip) == 0
      end 
    else
      mvalues[0]
    end

    raise "Could not determine material values for #{color} from #{mvalues}" if mval.nil?
    mval
  end

  def color_options(descriptor = material_descriptor)
    opts = Option.new(properties.find_by_descriptor(descriptor)).map do |p| 
      p.property_values.select{|v| !v.dvinci_id.nil?}.inject([]) do |m, v| 
        m << ColorOption.new(v.dvinci_id, v.color)
      end
    end
    
    opts.orSome([])
  end
end

module PanelEdgePricing
  include Expressions

  def edge_materials(sides, color)
    sides.inject({}) do |result, side|
      properties.find_by_family_with_qualifier(:edge_band, side).each do |prop|
        mvalues = prop.property_values.all
        material = if mvalues.empty?
          raise "Could not determine material values from #{prop}"
        elsif mvalues.length > 1 
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
