class CreateItemCategories < ActiveRecord::Migration
  def self.up
    execute "update items set category = 'wood-classic' where category = 'wood'"
    create_table :item_categories do |t|
      t.string :category
      t.string :sort_group
    end

    execute "insert into item_categories(category, sort_group) values ('flooring_expendables', 'accessories')"
    execute "insert into item_categories(category, sort_group) values ('flooring_hardware', 'accessories')"
    execute "insert into item_categories(category, sort_group) values ('selling_tools', 'accessories')"
    execute "insert into item_categories(category, sort_group) values ('flooring', 'accessories')"
    execute "insert into item_categories(category, sort_group) values ('closet_accessories', 'accessories')"
    execute "insert into item_categories(category, sort_group) values ('organizers', 'accessories')"
    execute "insert into item_categories(category, sort_group) values ('hardware', 'accessories')"
    execute "insert into item_categories(category, sort_group) values ('board', 'accessories')"
    execute "insert into item_categories(category, sort_group) values ('wood-classic', 'wood')"
    execute "insert into item_categories(category, sort_group) values ('wood-nx', 'wood')"
    execute "insert into item_categories(category, sort_group) values ('barrett-jackson', 'wood')"
  end

  def self.down
    drop_table :item_categories
  end
end
