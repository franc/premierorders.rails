module JobsHelper
  def unit_price_mismatch(job_item)
    job_item.compute_unit_price.bind do |computed_price|
      difference = (computed_price - job_item.unit_price).to_f
      Option.iif(difference.abs / computed_price.to_f > 0.005) { difference }
    end
  end

  def unit_price_class(job_item)
    cls = job_item.compute_unit_price.map do |computed_price|
      difference = (computed_price - job_item.unit_price).to_f
      if difference.abs / computed_price.to_f > 0.005
        "unit_price_mismatch"
      else
        ""
      end
    end

    cls.orSome("price_not_computed")
  end
end
