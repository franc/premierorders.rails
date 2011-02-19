require 'util/option'

module JobsHelper
  def unit_price_mismatch(job_item)
    job_item.compute_unit_price.bind do |computed_price|
      computed_price.right.toOption.bind do |success|
        difference = (success - job_item.unit_price).to_f
        Option.iif(difference.abs / success.to_f > 0.005) { difference }
      end
    end
  end

  def unit_price_class(job_item)
    job_item.compute_unit_price.cata( 
      lambda do |computed_price|
        computed_price.cata(
          lambda do |error| 
            'price_calculation_error'
          end,
          lambda do |success|
            difference = (success - job_item.unit_price).to_f
            (difference.abs / success.to_f) > 0.005 ? 'unit_price_mismatch' : ''
          end
        )
      end,
      'price_not_computed'
    )
  end

  def action_links(job)
    if can? :manage, job
      [link_to('Manage', job), link_to('Edit', edit_job_path(job)), link_to('Cutrite', cutrite_job_path(job))] + 
      Option.iif(can? :destroy, job){ link_to('Delete', job, :confirm => 'Are you sure?', :method => :delete) }.to_a
    else 
      [link_to('Manage', job)] +
      Option.iif(can? :update, job){ link_to('Edit', edit_job_path(job)) }.to_a + 
      Option.iif(can? :destroy, job){ link_to('Delete', job, :confirm => 'Are you sure?', :method => :delete) }.to_a
    end
  end
end
