class RenameSushiListItems < ActiveRecord::Migration
  def self.up
    execute("UPDATE items SET type = 'Items::ConfiguredItem' WHERE type = 'Items::SushiListItem'");
    execute("UPDATE item_components SET type = 'Items::ConfiguredComponent' WHERE type = 'Items::SushiItemChoice'");
  end

  def self.down
    execute("UPDATE items SET type = 'Items::SushiListItem' where type = 'Items::ConfiguredItem'");
    execute("UPDATE item_components SET type = 'Items::SushiItemChoice' WHERE type = 'Items::ConfiguredComponent'");
  end
end
