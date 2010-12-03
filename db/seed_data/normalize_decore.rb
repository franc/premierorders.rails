require 'csv'
require 'set'

colors = Set.new
styles = Set.new
refs = Set.new
ids = Set.new

style_refs = {}
price_refs = {}

CSV.open('decore_pricing.csv', 'r') do |row| 
  item, mpn, cost, cost_uom, option_cost, option_uom, handling_cost, handling_uom = row

  ref = mpn[/(#.*)/, 1].strip
  id, color, *rest = mpn.gsub(/(,\s*)?#.*/, '').split(',').map{|s| s.strip}
  style = rest.join(', ')

  refs.add(ref)
  ids.add(id)
  colors.add(color)
  styles.add(style)

  sref = [style, ref]
  cost_set = [cost, option_cost, handling_cost].map{|v| v.to_f}
  if price_refs[cost_set].nil?
    price_refs[cost_set] = [Set.new(style), Set.new(color), Set.new(id)]
  else
    price_refs[cost_set][0].add(style)
    price_refs[cost_set][1].add(color)
    price_refs[cost_set][2].add(id)
  end
#  if style_refs[style].nil?
#    style_refs[style] = {cost_set => [Set.new(color), Set.new(id)]}
#  else
#    if style_refs[style][cost_set].nil? 
#      style_refs[style][cost_set] = [Set.new(color), Set.new(id)]
#    else
#      style_refs[style][cost_set][0].add(color)
#      style_refs[style][cost_set][1].add(id)
#    end
#  end

  #puts ("%10s, %15s, %30s, %30s, %10s, %10s, %10s, %10s, %10s, %10s" % [ref, id, color, style, cost, cost_uom, option_cost, option_uom, handling_cost, handling_uom])
end

def disp_h(hash, level, indent)
  hash.to_a.sort.each do |key, value|
    puts "#{" " * (indent * level)}#{key.inspect}: {"
    if value.kind_of? Hash
      disp_h(value, level + 1, indent)
    else
      puts "#{" " * (indent * (level + 1))}#{value.inspect}"
    end
    puts "#{" " * (indent * level)}}"
  end
end

#disp_h(price_refs, 0, 4)
price_refs.map{ |k, v| v.map{|s| s.to_a} + k }.sort.each do |v|
  puts v.inspect
end


#style_refs.to_a.sort.each do |key, value|
#  puts "#{key}: {"
#  value.to_a.sort.each do |key, value|
#    puts "    #{key.join(' ')}: {"
#    value.to_a.sort.each do |key, value|
#      puts "        #{key}: #{value.inspect}" 
#    end
#    puts "    }"
#  end
#  puts "}"
#end

#puts refs.to_a.sort.inspect
#puts
#puts ids.to_a.sort.inspect
#puts
#puts colors.to_a.sort.inspect
#puts
#puts styles.to_a.sort.inspect
#puts
