class FillBulkQty < ActiveRecord::Migration
  def self.up
    Item.where("name ilike '%box%'").each do |item|
      matches = item.name.match(/(Box\s*Qty\s*(\d+)|(\d+)\s*\/\s*box)/i)
      if matches
        item.type = 'Items::BulkItem'
        item.bulk_qty = matches.captures[1] || matches.captures[2]
        item.save
      end
    end
  end

  def self.down
  end
end
