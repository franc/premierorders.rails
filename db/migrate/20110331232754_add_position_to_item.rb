class AddPositionToItem < ActiveRecord::Migration
  def self.up
    add_column :items, :position, :int

    Item.where(:in_catalog => true).order(:category, :name).each_with_index do |item, i|
      item.update_attributes(:position => i)
    end
  end

  def self.down
    remove_column :items, :position
  end
end
