class Items::Shell < Item
  def self.component_association_types
    super.merge({:required => [Items::ShellVerticalPanel, Items::ShellHorizontalPanel], :optional => [Items::ShellBackPanel]}) do |k, v1, v2|
      v1 + v2
    end
  end
end
