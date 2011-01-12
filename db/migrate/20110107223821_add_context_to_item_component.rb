class AddContextToItemComponent < ActiveRecord::Migration
  def self.up
    add_column :item_components, :context_names, :string
  end

  def self.down
    remove_column :item_components, :context_names
  end
end
