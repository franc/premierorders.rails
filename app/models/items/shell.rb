require 'items/shell_components.rb'

class Shell < Item
  def self.component_association_types
    {:required => [ShellVerticalPanel, ShellHorizontalPanel, ShellBackPanel]}
  end

  # Computes the price for a job item where the associated item is an instance of Shell
  def calculate_price(width, height, depth, units, color)
    item_components.inject(0.0) do |total, component_conf|
      total + component_conf.calculate_price(width, height, depth, units, color)
    end
  end
end
