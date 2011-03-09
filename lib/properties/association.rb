require 'fp'

module Properties
  module Association
    def find_by_family_with_qualifier(family, qualifier)
      find(:all, :conditions => ['family = ? and qualifier = ?', family, qualifier])
    end

    def find_all_by_descriptor(descriptor)
      conditions = descriptor.qualifiers.empty? ? ['family = ?', descriptor.family] : ['family = ? and qualifier in (?)', descriptor.family, descriptor.qualifiers]
      find(:all, :conditions => conditions)
    end


    def find_by_descriptor(descriptor)
      conditions = descriptor.qualifiers.empty? ? ['family = ?', descriptor.family] : ['family = ? and qualifier in (?)', descriptor.family, descriptor.qualifiers]
      find(:first, :conditions => conditions)
    end

    def find_value(descriptor)
      Option.new(find_by_descriptor(descriptor)).mapn{|p| p.property_values.first}
    end
  end
end
