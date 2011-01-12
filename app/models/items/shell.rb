require 'items/shell_components.rb'

class Shell < Item
  def self.component_association_types
    {:required => [ShellVerticalPanel, ShellHorizontalPanel], :optional => [ShellBackPanel]}
  end
end
