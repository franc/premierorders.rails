require 'fp'

module JobsHelper
  def action_links(job)
    links = []
    links << link_to('Edit', edit_job_path(job)) if can? :update, job
    links << link_to('Cutrite', cutrite_job_path(job)) if can? :pg_internal_cap, job
    links << link_to('Delete', job_path(job), :confirm => 'Are you sure?', :method => :delete) if can? :destroy, job
    links
  end

  def job_status_select(job)
    select_tag(
      "job[#{job.id}][status]", 
      options_for_select(Job::STATUS_OPTIONS.map{|v| [v,v]}, job.status), 
      :class => 'job_status'
    ) 
  end

  def job_production_batch_select(job)
    if (job.production_batches_closed? || job.status.nil? || job.status == 'Created') 
      job.production_batches.to_a.map{|b| b.name}.join("<br/>") 
    else
      production_batch_select(job)   
    end
  end

  def job_ship_method_select(job, options = {})
    select_tag(
      "job[#{job.id}][ship_method]", 
      options_for_select(Job::SHIPMENT_OPTIONS.map{|v| [v,v]}, job.ship_method), 
      options.merge({ :class => 'job_ship_method'})
    )
  end
end
