require 'rexml/document'
require 'csv'
require 'json'
require 'property.rb'
require 'util/option.rb'

class Job < ActiveRecord::Base
  belongs_to :franchisee
  belongs_to :primary_contact, :class_name => 'User'
  belongs_to :customer, :class_name => 'User'
  belongs_to :billing_address, :class_name => 'Address'
  belongs_to :shipping_address, :class_name => 'Address'
  has_many   :job_items
  has_many   :job_properties, :extend => Properties::Association

  has_attached_file :dvinci_xml

  STATUS_OPTIONS = [
    ["Created" , "Created"],
    ["In Review" , "In Review"],
    ["Confirmed" , "Confirmed"],
    ["On Hold" , "On Hold"],
    ["Ready For Production" , "Ready For Production"],
    ["In Production" , "In Production"],
    ["Ready to Ship" , "Ready to Ship"],
    ["Hold Shipment" , "Hold Shipment"],
    ["Shipped" , "Shipped"],
    ["Cancelled" , "Cancelled"]
  ]

  def ship_to
    shipping_address || franchisee.shipping_address
  end

  def property_names
    job_items.inject([]) do |names, job_item|
      names + job_item.job_item_properties.map{|a| a.name}
    end
  end

  def decompose_xml(xml)
    doc = REXML::Document.new(xml)
    doc.get_elements("//Row").inject([]) do |rows, row_element|
      rows << row_element.get_elements("Cell/Data").map{|cell| cell.text}
    end
  end 

  def decompose_csv(csv)
    rows = []
    CSV.open(csv.path, "r", nil, "\r") do |row|
        rows << row
      logger.info("Got row: #{row.inspect}")
    end

    rows
  end 

  SKIP_ROWS = [
    /Subtotals/,
    /Taxes/,
    /Material Tax/,
    /Totals/,
    /Final Totals/,
    /RPM Products Total Weight/
  ]

  def add_items_from_dvinci(file)

    rows = case File.extname(file.path)
      when '.xml' then decompose_xml(file)
      when '.csv' then decompose_csv(file)
      else raise "Did not recognize file type for #{File.extname(file.path)}"
    end

    labels, data_rows = rows.partition {|row| row[0] == 'Description'}

    job_properties.create(
      :family => :linear_units,
      :module_names => Property::LinearUnits,
      :value_str => {:linear_units => :ft}.to_json
    )

    raise FormatException, "Unexpected number of label rows in document: #{labels.size}; expected 1" unless labels.size == 1
    labels.flatten!

    missing_columns = ['# of Items in Design', 'Description', 'Part Number'] - labels
    raise FormatException, "Did not find required columns in document: #{missing_columns.inspect}" unless missing_columns.empty?

    column_indices = (0...labels.size).zip(labels).inject({}) { |m, l| m[l[1]] = l[0]; m }

    min_columns = labels.any? {|l| l =~ /Notes/} ? labels.size - 1 : labels.size
    item_rows = data_rows.select do |r| 
      r.size >= min_columns && 
      r[column_indices['Part Number']] && 
      !SKIP_ROWS.any?{|l| r[0].to_s =~ l}
    end

    item_rows.each_with_index do |row, i|
      logger.info "Processing data row: #{row.inspect}"
      dvinci_product_id = row[column_indices['Part Number']]
      product_code_matchdata = dvinci_product_id.match(/(\d{3})\.(\w{3})\.(\w{3})\.(\d{3})\.(\d{2})(\w)/)
      logger.info product_code_matchdata.inspect
      item = Option.new(
        if product_code_matchdata
          t1, t2, t3, color_key, t5, t6 = product_code_matchdata.captures
          logger.info "Find: #{t1}.#{t2}.#{t3}.x.#{t5}#{t6}"
          Item.find_by_dvinci_id("#{t1}.#{t2}.#{t3}.x.#{t5}#{t6}") || Item.find_by_dvinci_id(dvinci_product_id)
        else 
          Item.find_by_dvinci_id(dvinci_product_id)
        end
      )

      logger.info "Item: #{item.inspect}"

      unlabeled_col_values = ((0...row.size).to_a - column_indices.values).map{|i| row[i]}
      special_instructions = if column_indices['Notes'] 
        (unlabeled_col_values << row[column_indices['Notes']]).join("; ")
      else
        unlabeled_col_values.join("; ")
      end

      item_quantity = row[column_indices['# of Items in Design']].to_i
      unit_price    = row[column_indices['Material Charge']].gsub(/\$/,'').strip.to_f / item_quantity
      job_item_properties = {
          :ingest_id => dvinci_product_id,
          :quantity  => item_quantity,
          :comment   => special_instructions,
          :unit_price => unit_price,
          :tracking_id => i + 1
      }

      # Add the item reference to the job item, if an item is known
      item.each{|i| job_item_properties[:item_id] = i.id}

      job_item = job_items.create(job_item_properties)

      dimensions_data = { }
      Option.fromString(row[column_indices['Cut Height']]).each{|v| dimensions_data[:height] = v}
      Option.fromString(row[column_indices['Cut Width']]).each{|v| dimensions_data[:width] = v}
      Option.fromString(row[column_indices['Cut Depth']]).each{|v| dimensions_data[:depth] = v}

      item.bind{|i| Option.new(i.class.job_item_properties.find{|d| d.family == :dimensions})}.each do |descriptor|
        job_item.job_item_properties.create(
          :family => descriptor.family,
          :module_names => descriptor.module_names,
          :value_str => dimensions_data.to_json 
        )
      end

      item.each do |i|
        color_pv = i.properties.find_by_descriptor(Property::Color::DESCRIPTOR).property_values.detect{|pv| pv.dvinci_id == color_key}
        logger.info color_pv.inspect
        job_item.job_item_properties.create(
          :family => Property::Color::DESCRIPTOR.family,
          :module_names => Property::Color::DESCRIPTOR.module_names,
          :value_str => {:color => color_pv.color}.to_json
        )    
      end
    end
  end

  def to_cutrite_data
    job_lines  = [cutrite_job_header, cutrite_job_data]
    item_lines = [cutrite_items_header] + cutrite_items_data

    (job_lines + item_lines)
  end

  def to_cutrite_csv
    to_cutrite_data.map{|l| CSV.generate_line(l)}.join("\n")
  end

  def cutrite_job_header
    [
      '',
      'Job Name',
      '',
      '',
      '',
      'Account Name',
      'Shipping Address',
      'Shipping City Shipping State Shipping Postal Code',
      'Phone',
      'Fax',
      'MFG Plant'
    ]
  end

  def cutrite_job_data
    [
      '',
      name,
      '', '', '',
      franchisee.franchise_name,
      shipping_address.address1 + (shipping_address.address2 || ''),
      "#{ship_to.city} #{ship_to.state} #{ship_to.postal_code}",
      franchisee.phone,
      franchisee.fax,
      mfg_plant
    ]
  end

  def cutrite_items_header
    [
      'qty', 'comment', 'width', 'height', 'depth', 'CutRite Product ID', 'Description',
      'Cabinet Color', 'Case Material', 'Case Edge', 'Case Edge 2',
      'Door Material', 'Door Edge'
    ]
  end

  def cutrite_items_data
    job_items.order('tracking_id', 'items.name').all.select{|job_item| job_item.item && job_item.item.cutrite_id && !job_item.item.cutrite_id.strip.empty?}.map{|job_item| cutrite_item_data(job_item)}
  end

  private

  def cutrite_item_data(job_item)
    basic_attr_values = [
      job_item.quantity.to_i,
      job_item.comment,
      job_item.property('Width').width(:mm),
      job_item.property('Height').height(:mm),
      job_item.property('Depth').depth(:mm),
      job_item.item.nil? ? nil : job_item.item.cutrite_id,
      job_item.item.nil? ? job_item.item_attr('description') : job_item.item.name
    ]

    cutrite_custom_attributes = [
      'Cabinet Color',
      'Case Material',
      'Case Edge',
      'Case Edge2',
      'Case Material',
      'Case Edge'
    ]

    custom_attr_values = cutrite_custom_attributes.map { |name| job_item.item_attr(name) }

    basic_attr_values + custom_attr_values
  end
end

class FormatException < RuntimeError
  attr :message
  def initialize(message)
    @message = message
  end
end
