module Properties
  module ModularProperty
    def value_structure
      modules.inject([]){|m, mod| m + mod.value_structure}.uniq  
    end
  end
end


