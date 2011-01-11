require 'items/panel.rb'

class Countertop < FinishedPanel
  def self.banded_edges
    {:front => W, :left => D, :right => D}
  end

  def self.l_expr 
    W
  end

  def self.w_expr
    D
  end
end
