class ReportsController < ApplicationController
  before_filter do
    authorize! :view_reports, :all
  end
  
  def sales
    @start_date = params[:start_date]
    @end_date   = params[:end_date]
    @franchisee = Franchisee.find_by_id(params[:franchisee_id])
    @franchisees = Franchisee.all

    if @start_date && @end_date && @franchisee
      @jobs = Job.where(['franchisee_id = ? and ship_date >= ? and ship_date <= ?', @franchisee.id, @start_date, @end_date]) 

      zero = BigDecimal.new("0.0")
      @report_data = @jobs.inject({}) do |results, job|
        job.job_items.each do |job_item|
          sales_category = job_item.sales_category || 'Other'
          results[sales_category] ||= {
            :manufactured => zero,
            :buyout => zero,
            :bulk_inventory => zero
          }

          if job_item.inventory? 
            results[sales_category][:bulk_inventory] += job_item.net_total
          elsif job_item.buyout?
            results[sales_category][:buyout]         += job_item.net_total
          else
            results[sales_category][:manufactured]   += job_item.net_total
            results[sales_category][:bulk_inventory] += job_item.hardware_total
          end
        end

        results
      end
    else
      @report_data = {}
    end
  end
end
