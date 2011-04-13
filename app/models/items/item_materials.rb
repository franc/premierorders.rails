require 'fp'

module Items::ItemMaterials
  # retrieve the material property values by color.
  def material(descriptor, color)
    mprop = properties.find_by_descriptor(descriptor)
    mvalues = mprop.property_values.all
    mval = if mvalues.empty?
      raise "Could not determine material values from #{mprop}" 
    elsif mvalues.length > 1 
      mvalues.detect do |v| 
        (v.respond_to?(:dvinci_id) && v.dvinci_id && color && v.dvinci_id.strip == color.strip) || 
        (v.color && color && v.color.strip.casecmp(color.strip) == 0)
      end 
    else
      mvalues[0]
    end

    raise "Could not determine material values for #{color} from: \n#{mvalues.join("\n")}" if mval.nil?
    mval
  end

  def color_options(descriptor = material_descriptor)
    opts = Option.new(properties.find_by_descriptor(descriptor)).map do |p| 
      p.property_values.select{|v| !v.dvinci_id.nil?}.inject([]) do |m, v| 
        m << Items::ColorOption.new(v.dvinci_id, v.color)
      end
    end
    
    opts.orSome([])
  end
end

