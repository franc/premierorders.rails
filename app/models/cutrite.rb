require 'item_queries'
require 'fp'

module Cutrite
  CUTRITE_ADDRESS_HEADER = [
    'Account Name',
    'Shipping Address',
    'Shipping City State Postal Code',
    'Phone',
    'Fax',
    'MFG Plant'
  ]

  CUTRITE_ITEMS_HEADER = [
    'qty', 'comment', 'width', 'height', 'depth', 'CutRite Product ID', 'Description',
    'Cabinet Color', 'Case Material', 'Case Edge', 'Case Edge 2',
    'Door Material', 'Door Edge', 
    'SO Number', 'Job Name'
  ] + CUTRITE_ADDRESS_HEADER

  def to_cutrite_csv
    to_cutrite_data.map{|l| CSV.generate_line(l)}.join("\n")
  end

  def cutrite_items_data(units = :mm)
    job_items.order('tracking_id').select{|job_item| job_item.item && job_item.item.cutrite_id && !job_item.item.cutrite_id.blank?}.map{|job_item| cutrite_item_data(job_item, units)}
  end

  def cutrite_item_data(job_item, units = :mm)
    basic_attr_values = [
      job_item.quantity.to_i,
      job_item.comment,
      job_item.width(units).map{|v| "%.1f" % v}.orSome(''),
      job_item.height(units).map{|v| "%.1f" % v}.orSome(''),
      job_item.depth(units).map{|v| "%.1f" % v}.orSome(''),
      job_item.item.nil? ? '' : job_item.item.cutrite_id,
      job_item.item_name      
    ]

    custom_attr_values = job_item.dvinci_color_code.map do |color_code|
      thickness_pref = lambda do |v1, v2| 
        if    (v1.thickness(:mm) == 19 || v1.thickness(:in) == 0.75) then v1 
        elsif (v2.thickness(:mm) == 19 || v2.thickness(:in) == 0.75) then v2
        else                                                              v1 
        end
      end

      #logger.info("Querying for panel material for #{job_item.item_name}")
      panel_query = ItemQueries::ColorQuery.new('panel_material', color_code, &thickness_pref) 
      query_context = ItemQueries::QueryContext.new()
      panel_material = Option.new(job_item.item).bind do |i| 
        i.query(panel_query, query_context)
      end

      #logger.info("Querying for door material for #{job_item.item_name}")
      door_query = ItemQueries::ColorQuery.new('door_material', color_code, &thickness_pref) 
      door_material = Option.new(job_item.item).bind do |i| 
        i.query(door_query, query_context)
      end

      eb_query = ItemQueries::ColorQuery.new('edge_band', color_code) do |v1, v2| 
        v1.width == 19 ? v1 : v2
      end
      eb_material = Option.new(job_item.item).bind {|i| i.query(eb_query, query_context)}

      eb2_query = ItemQueries::ColorQuery.new('edge_band', color_code) do |v1, v2| 
        v1.width == 25 ? v1 : v2
      end

      eb2_material = Option.new(job_item.item).bind {|i| i.query(eb2_query, query_context)}

      [
        panel_material.orElse(door_material).map{|m| m.color}.orSome(''),
        panel_material.orElse(door_material).map{|m| m.cutrite_code}.orSome(''),
        eb_material.map{|m| m.cutrite_code}.orSome(''),
        eb2_material.map{|m| m.cutrite_code}.orSome(''),
        door_material.orElse(panel_material).map{|m| m.cutrite_code}.orSome(''),
        eb_material.map{|m| m.cutrite_code}.orSome('')
      ]
    end

    item_data = (
      basic_attr_values + 
      custom_attr_values.orSome(['','','','','','']) + 
      ["#{job_item.job.job_number}/#{job_item.tracking_id}", job_item.job.name] + 
      job_item.job.cutrite_address_data
    )
    
    item_data.map do |v| 
      v.to_s.gsub(/[,'"]/,'')
    end
  end
end
