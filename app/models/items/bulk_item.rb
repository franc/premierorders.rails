class BulkItem < Item

  def base_cost_expr(query_context)
    if bulk_qty.nil? || query_context.use_bulk_pricing?
      super
    else
      super.map{|base_cost| base_cost / term(bulk_qty)}
    end
  end
end
