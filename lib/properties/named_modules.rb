module Properties::NamedModules
  def modules
    (module_names || '').split(/\s*,\s*/).map do |mod_name|
      Property.const_get(mod_name.demodulize.to_sym)
    end
  end
end


