require 'items/shell_components.rb'

class Shell < Item
  def self.component_association_types
    super.merge({:required => [ShellVerticalPanel, ShellHorizontalPanel], :optional => [ShellBackPanel]}) do |k, v1, v2|
      v1 + v2
    end
  end
end
