class Panel < Item
  include ItemMaterials

  def calculate_price(w, l, material)
    w * l * material_attr.price(material)
  end
end
