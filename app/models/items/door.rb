require 'properties'
require 'expressions'
require 'fp'

class Items::Door < Items::FinishedPanel
  include Items::ItemMaterials, Items::PanelEdgePricing

  def self.banded_edges
    {:left => H, :right => H, :top => W, :bottom => W}
  end

  def l_expr
    H
  end

  def w_expr
    W
  end
end


