class Panel < Item
  include ItemMaterials

  def calculate_price(w, l, material)
    w * l * material_property('Case Material').price(material)
  end
end
