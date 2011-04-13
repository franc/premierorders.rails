module Properties
  module SquareConversions
    UNITS = [:mm, :in, :ft]

    def sq_convert(value, from, to)
      case from.to_sym
      when :mm
        case to.to_sym
        when :mm then value
        when :in then value / (25.4**2)
        when :ft then (value / (25.4**2)) / (12**2)
        end
      when :in
        case to.to_sym
        when :in then value
        when :mm then value * (25.4**2)
        when :ft then value / (12**2)
        end
      when :ft
        case to.to_sym
        when :in then value * (12**2)
        when :mm then value * (12**2) * (25.4**2)
        when :ft then value
        end
      end
    end
  end
end

