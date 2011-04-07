require 'fp'

module JobItemsHelper
  def unit_price_class(job_item)
    job_item.unit_price_mismatch
    if job_item.computed_unit_price
      job_item.unit_price_mismatch.empty? ? '' : 'unit_price_mismatch'
    else
      case job_item.pricing_cache_status.try(:to_sym)
        when :ok    then ''
        when :error then 'price_calculation_error'
        when :not_computed then 'price_not_computed'
        else
          'price_not_computed'
      end
    end
  end

  def price_computation_error(job_item)
    job_item.compute_unit_price.map{|p| p.left.toOption.map{|err| "<pre>#{err}</pre>"}}.orElse(
      Option.some("Could not determine catalog item for job item #{@job_item.ingest_desc} (#{@job_item.ingest_id})")
    )
  end
end
