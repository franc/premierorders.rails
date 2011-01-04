require 'items/panel.rb'

class BackingPanel < Item
  include PanelItem

  def self.banded_edges
    {}
  end

  def self.l_expr 
    'H'
  end

  def self.w_expr
    'W'
  end
end
