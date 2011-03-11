require 'fp'

module JobsHelper
  def action_links(job)
    if can? :manage, job
      [link_to('Edit', edit_job_path(job)), link_to('Cutrite', cutrite_job_path(job))] + 
      Option.iif(can? :destroy, job){ link_to('Delete', job, :confirm => 'Are you sure?', :method => :delete) }.to_a
    else 
      Option.iif(can? :update, job){ link_to('Edit', edit_job_path(job)) }.to_a + 
      Option.iif(can? :destroy, job){ link_to('Delete', job, :confirm => 'Are you sure?', :method => :delete) }.to_a
    end
  end

  def job_status_select(job)
    select_tag(
      "job[#{job.id}][status]", 
      options_for_select(Job::STATUS_OPTIONS.map{|v| [v,v]}, job.status), 
      :class => 'job_status'
    ) 
  end

  def job_ship_method_select(job)
    select_tag(
      "job[#{job.id}][ship_method]", 
      options_for_select(Job::SHIPMENT_OPTIONS.map{|v| [v,v]}, job.ship_method), 
      :class => 'job_ship_method'
    )
  end
end
