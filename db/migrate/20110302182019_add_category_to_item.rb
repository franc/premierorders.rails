require 'db/sushi_loader.rb'

class AddCategoryToItem < ActiveRecord::Migration

  def self.up
    add_column :items, :category, :string
    add_column :items, :in_catalog, :boolean, :nullable => false, :default => false
    SushiLoader.load_wood_items
    SushiLoader.load_sushi_items('board')
    SushiLoader.load_sushi_items('closet')
    SushiLoader.load_sushi_items('expendables')
    SushiLoader.load_sushi_items('flooring')
    SushiLoader.load_sushi_items('hardware')
    SushiLoader.load_sushi_items('organizers')
    SushiLoader.load_sushi_items('selling_tools')
    SushiLoader.load_sushi_items('tools')
  end

  def self.down
    remove_column :items, :category
  end
end
