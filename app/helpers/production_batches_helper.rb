module ProductionBatchesHelper
  def production_batch_select(job)
    option_tags = options_for_select(
      ProductionBatch.find_all_by_status(:open).map{|batch| [batch.name, batch.id]},
      job.production_batches.to_a.map{|b| b.id}
    )

    select_opts = {
       :class => 'job_production_batch', 
       :include_blank => true
    }

    if (job.production_batches.size > 1) 
      select_opts[:multiple] = true
    end

    select_tag("job[#{job.id}][production_batch_id]", option_tags, select_opts) 
  end
end
