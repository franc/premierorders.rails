class Cabinet < Item
  def price_job_item(job_item)
    units       = job_item.job.job_property("Units").units
    width       = job_item.property("Width").width
    height      = job_item.property("Height").height
    height      = job_item.property("Depth").depth
    color       = job_item.property("Cabinet Color")

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
