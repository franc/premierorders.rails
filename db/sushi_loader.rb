require 'csv'
require 'item_queries'

module SushiLoader
  def self.load_wood_items
    CSV.open("db/seed_data/sushi_list/wood.csv", 'r') do |row|
      desc, item_name, purchase_part_id, w, l, color, edge, cost, *xs = row

      item = Item.find_by_name(item_name) || Item.find_by_purchase_part_id(purchase_part_id)
      if item
        sli = Items::SushiListItem.create(
          :name => desc,
          :category => 'wood',
          :purchase_part_id => purchase_part_id,
          :sell_price => cost,
          :in_catalog => true
        )

        Items::SushiItemChoice.create(
          :item => sli,
          :component => item,
          :quantity => 1
        )

        desc_md = desc.match(/([\d\.]*)\s*x\s*([\d\.]*)/)
        if desc_md
          if l.blank?
            l = desc_md.captures[1]
          end 
          if w.blank?
            w = desc_md.captures[2]
          end
        end

        if w.blank? || l.blank?
          puts("Could not find width or length for #{row.inspect}")
        else
          area_prop = Items::SushiListItem::AREA.create_property("#{item_name} dimensions (#{w} x #{l})")
          area_value = area_prop.create_value(
            "#{item_name} dimensions (#{w} x #{l})",
            :width => w,
            :length => l,
            :linear_units => :in
          )
          ItemProperty.create(:item => sli, :property => area_prop)

          item.query(ItemQueries::ColorNameQuery.new('panel_material', color), []).each do |material_val|
            material_prop = Items::Panel::MATERIAL.create_property("#{item_name} material (#{color})")
            material_prop.property_values << material_val
            material_prop.save
            ItemProperty.create(:item => sli, :property => material_prop)
          end

          item.query(ItemQueries::ColorNameQuery.new('edge_band', edge), []).each do |edge_val|
            edge_prop = Items::SushiListItem::EDGE_BANDING.create_property("#{item_name} edge banding (#{edge})")
            edge_prop.property_values << edge_val
            edge_prop.save
            ItemProperty.create(:item => sli, :property => edge_prop)
          end
        end
        print '.'
      else
        Item.create(
          :name => desc,
          :category => 'wood',
          :purchase_part_id => purchase_part_id,
          :sell_price => cost,
          :in_catalog => true
        )
        print '-'
      end
    end
  end

  def self.load_sushi_items(category)
    File.open("price_mismatch.out", "w") do |f|
      CSV.open("db/seed_data/sushi_list/#{category}.csv", 'r') do |row|
        desc, purchase_part_id, cost = row

        item = Item.find_by_purchase_part_id(purchase_part_id)
        # if item 
        #   begin
        #     db_price = item.retail_price_expr(:in, nil, []).evaluate({})
        #     f.println(row + [db_price]) unless db_price == BigDecimal.new(cost)
        #   rescue
        #     puts "\nError obtaining price expression: #{$!}\n#{$!.backtrace[0]}"
        #   end
        #   item.update_attributes(:in_catalog => true, :category => category)
        #   print '.'
        # else
        if item.nil?
          Item.create(
            :name => desc,
            :category => category,
            :purchase_part_id => purchase_part_id,
            :sell_price => cost,
            :in_catalog => true
          )
          print '-'
        end
      end
    end
  end
end
