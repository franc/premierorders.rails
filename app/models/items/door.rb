class PremiumDoor < Item
  def calculate_price(style, color)
    style_attr = item_attrs.find_by_name('style')
    color_attr = item_attrs.find_by_name('color')
    pricing_rule = item_pricing.find_all.find do |pricing|
      style_options = pricing.item_attr_options.find_all_by_item_attr_id(style_attr.id)
      color_options = pricing.item_attr_options.find_all_by_item_attr_id(color_attr.id)

      style_options.any?{||opt| opt.value_str == style} && color_options.any?{||opt| opt.value_str == color}
    end
  end
end

class FrenchLiteDoor < PremiumDoor
  def calculate_price(style, color, options)
    base_price = super(style, color, options)


  end
end