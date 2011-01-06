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
              begin
                price = eval(pricing_expr.gsub(/W/, 'w').gsub(/H/, 'h').gsub(/D/, 'd'))
                delta = colors[i].gsub(/\$/, '').to_f - price 
                result += [colors[i], price, delta]
              rescue
                puts "Got error in calculation for #{item.inspect} with #{pricing_expr}: #{$!.inspect}"
              end
            end
          end
          result
        end

        CSV.open("test/csv/master_pg_pricelist_v010511.csv", "r") do |row|
          name, shelves, w, h, d, ignore, *colors = row
          if name == 'Description'
            color_keys += colors.select{|c| !c.blank?}
            csv << ([name, shelves, w, h, d, nil] + colors.map{|c| [c, "#{c}-calculated", "#{c}-delta"]}.flatten)
          else
            item = if name.strip == 'Drawer Box'
              Item.find_by_name("Drawer Box #{h} H")
            else
              Item.find_by_name(name.strip)
            end

            if item
              if shelves.blank?
                csv << ([name, shelves, w, h, d, ignore] + prices.call(w.to_f, h.to_f, d.to_f, item, colors))
              else
                if item.item_components.detect{|c| c.class == CabinetShelf && c.quantity == shelves.to_i}
                  csv << ([name, shelves, w, h, d, ignore] + prices.call(w.to_f, h.to_f, d.to_f, item, colors))
                else
                  puts("No match for #{shelves} shelves in #{item.inspect}")
                end
              end
            else
              puts("Could not find item: #{name}")
            end
          end
        end
      end
    end
  end
end
