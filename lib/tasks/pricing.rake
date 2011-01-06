require 'csv'

namespace :pricing do 
  task :compare => :environment do
    File.open("master_pricelist_results.csv", "w") do |f|
      CSV::Writer.generate(f, ",") do |csv|
        color_keys = []

        prices = lambda do |w, h, d, item, colors|
          result = []
          color_keys.each_with_index do |color, i|
            unless colors[i].blank?
              pricing_expr = item.pricing_expr(:in, color)
              price = eval(pricing_expr.gsub(/W/, 'w').gsub(/H/, 'h').gsub(/D/, 'd'))
              delta = colors_i.to_f - price 
              result += [colors[i], price, delta]
            end
          end
          result
        end

        CSV.open("test/csv/master_pg_pricelist_v010511.csv", "r") do |row|
          name, shelves, w, h, d, ignore, colors* = row
          if name == 'Description'
            color_keys = colors
            next
          end
        
          item = Item.find_by_description(name)
          if shelves.blank?
            csv << ([name, shelves, w, h, d, ignore] + prices(w, h, d, item, colors))
          else
            if item.item_components.detect{|c| c.class == CabinetShelf && c.quantity == shelves.to_i}
              csv << ([name, shelves, w, h, d, ignore] + prices(w, h, d, item, colors))
            end
          end
        end
      end
    end
  end
end
