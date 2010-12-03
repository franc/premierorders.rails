class Drawer < Item
  include MaterialByColor

  def volume_attr
    item_attrs.find_by_type('Volume')
  end

  def volume
    item_attr_options.find_by_item_attr_id(volume_attr.id)
  end

  def calculate_price(width, depth, color)
    height = volume_attr.height(volume)
    width = width || volume_attr.width(volume)
    depth = depth || volume_attr.depth(volume)


  end
end
