class Cabinet < Item
  def price_job_item(job_item)
    if !job_item.item.kind_of?(Shell)
      raise "Illegal call to compute price for job item #{job_item} by logic for Shell"
    end

    width  = job_item.attr_value("width")
    height = job_item.attr_value("height")
    depth  = job_item.attr_value("depth")
    color  = job_item.attr_value("Cabinet Color")

    item_components.inject(0.0) do |total, conf|
      total + conf.calculate_price(width, height, depth, color)
    end
  end
end

class CabinetShell < ItemComponent
  def calculate_price(width, height, depth, color)
    quantity * component.calculate_price(width, height, depth, color)
  end
end

class CabinetDrawer < ItemComponent
  # The drawers associated with a cabinet will vary only with
  # respect to enclosing width and depth; drawer height will be fixed in
  # the drawer instance.
  def calculate_price(width, height, depth, color)
    quantity * component.calculate_price(width, depth, color)
  end
end
