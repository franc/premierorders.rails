class Items::BulkItem < Item

  def base_cost_expr(query_context)
    if bulk_qty.nil? || query_context.use_bulk_pricing?
      super
    else
      Option.new(base_price).filter{|p| p != 0}.map{|p| term((p / bulk_qty).round(2))}
    end
  end
end
