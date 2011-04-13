require 'csv'
require 'item_queries'

namespace :pricing do 
  task :compare => :environment do
    File.open("master_pricelist_results.csv", "w") do |f|
      CSV::Writer.generate(f, ",") do |csv|
        color_keys = []

        prices = lambda do |w, h, d, item, colors|
          result = []
          color_keys.each_with_index do |color, i|
            unless colors[i].blank?
              begin
                query_context = ItemQueries::QueryContext.new(:units => :in, :color => "%03d" % color.to_i)
                pricing_expr = item.rebated_cost_expr(query_context).map{|e| e.compile}.orLazy do 
                  raise "No pricing expression found."
                end

                begin
                  price = eval(pricing_expr.gsub(/W/, 'w').gsub(/H/, 'h').gsub(/D/, 'd'))
                  delta = colors[i].gsub(/\$/, '').to_f - price 
                  result += [colors[i], price, delta]
                rescue => err
                  puts "Got error in evaluation of #{pricing_expr} for #{item.name}: #{err.message}"
                  puts err.backtrace.join("\n")
                end
              rescue => err
                puts "Got error building pricing expression for #{item.name}: #{err.message}"
                #puts err.backtrace.join("\n")
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
            lookup_name = (name.strip == 'Drawer Box' ? "Drawer Box #{h} H" : name.strip)
            item = Item.find_by_name(lookup_name)

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
              puts("Could not find item for row: #{row.inspect} using name #{lookup_name}")
            end
          end
        end
      end
    end
  end
end
