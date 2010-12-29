require 'items/shell_components.rb'

class Shell < Item
  def self.component_association_types
    [ShellVerticalPanel, ShellHorizontalPanel, ShellBackPanel]
  end

  # Computes the price for a job item where the associated item is an instance of Shell
  def calculate_price(width, height, depth, units, color)
    item_components.inject(0.0) do |total, component_conf|
      component_price = component_conf.calculate_price(width, height, depth, units, color)
      total + component_price
    end
  end
end
