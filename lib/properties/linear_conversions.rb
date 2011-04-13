module Properties
  module LinearConversions
    UNITS = [:mm, :in, :ft]

    def convert(value, from, to)
      case from.to_sym
      when :mm
        case to.to_sym
        when :mm then value
        when :in then value / 25.4
        when :ft then (value / 25.4) / 12
        end
      when :in
        case to.to_sym
        when :in then value
        when :mm then value * 25.4
        when :ft then value / 12
        end
      when :ft
        case to.to_sym
        when :in then value * 12
        when :mm then value * 12 * 25.4
        when :ft then value
        end
      end
    end
  end
end
