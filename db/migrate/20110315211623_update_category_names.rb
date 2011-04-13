class UpdateCategoryNames < ActiveRecord::Migration
  def self.up
    execute("UPDATE items SET category = 'flooring_expendables' WHERE category = 'expendables'")
    execute("UPDATE items SET category = 'closet_accessories' WHERE category = 'closet'")
    execute("UPDATE items SET category = 'flooring_hardware' WHERE category = 'tools'")
  end

  def self.down
    execute("UPDATE items SET category = 'expendables' WHERE category = 'flooring_expendables'")
    execute("UPDATE items SET category = 'closet' WHERE category = 'closet_accessories'")
    execute("UPDATE items SET category = 'tools' WHERE category = 'flooring_hardware'")
  end
end
