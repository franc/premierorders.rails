class Items::MoldingNailer < Items::FinishedPanel
  def self.banded_edges
    {}
  end

  def l_expr 
    W
  end

  def w_expr
    D
  end
end
