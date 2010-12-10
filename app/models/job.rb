require 'rexml/document'
require 'csv'

class Job < ActiveRecord::Base
  belongs_to :franchisee
  belongs_to :primary_contact, :class_name => 'User'
  belongs_to :customer, :class_name => 'User'
  belongs_to :billing_address, :class_name => 'Address'
  belongs_to :shipping_address, :class_name => 'Address'
  has_many   :job_items, :include => :item
  has_many   :job_properties, :include => :property

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
    end

    rows
  end 

  def add_items_from_dvinci(file)
    dvinci_custom_properties = {
      'Cut Height' => Property.find_or_create_by_name_and_module_names('Height', 'Height'),
      'Cut Width'  => Property.find_or_create_by_name_and_module_names('Width', 'Width'),
      'Cut Depth'  => Property.find_or_create_by_name_and_module_names('Depth', 'Depth')
    }

    rows = case File.extname(file.path)
      when '.xml' then decompose_xml(file)
      when '.csv' then decompose_csv(file)
      else raise "Did not recognize file type for #{File.extname(file.path)}"
    end

    labels, data_rows = rows.partition {|row| row[0] == 'Description'}

    raise FormatException, "Unexpected number of label rows in document: #{labels.size}; expected 1" unless labels.size == 1
    labels.flatten!

    missing_columns = ['# of Items in Design', 'Description', 'Part Number'] - labels
    raise FormatException, "Did not find required columns in document: #{missing_columns.inspect}" unless missing_columns.empty?

    column_indices = (0...labels.size).zip(labels).inject({}) { |m, l| m[l[1]] = l[0]; m }

    min_columns = labels.any? {|l| l =~ /Notes/} ? labels.size - 1 : labels.size
    item_rows = data_rows.select{|r| r.size >= min_columns}

    item_rows.each_with_index do |row, i|
      logger.info "Processing data row: #{row.inspect}"
      dvinci_product_id = row[column_indices['Part Number']]
      product_code_matchdata = dvinci_product_id.match(/(\d{3})\.(\w{3})\.(\w{3})\.(\d{3})\.(\d{2})(\w)/)
      item = if product_code_matchdata
        t1, t2, t3, color_key, t5, t6 = product_code_matchdata.captures
        Item.find_by_dvinci_id("#{t1}.#{t2}.#{t3}.x.#{t5}#{t6}") || Item.find_by_dvinci_id(dvinci_product_id)
      else 
        Item.find_by_dvinci_id(dvinci_product_id)
      end

      unlabeled_col_values = ((0...row.size).to_a - column_indices.values).map{|i| row[i]}
      special_instructions = if column_indices['Notes'] 
        (unlabeled_col_values << row[column_indices['Notes']]).join("; ")
      else
        unlabeled_col_values.join("; ")
      end

      item_quantity = row[column_indices['# of Items in Design']].to_i
      job_item = if (item.nil?)
        job_items.create(
          :ingest_id => dvinci_product_id,
          :quantity  => item_quantity,
          :comment   => special_instructions,
          :unit_price => row[column_indices['Material Charge']].to_f / item_quantity,
          :tracking_id => i
        )
      else
        job_items.create(
          :item      => item,
          :ingest_id => dvinci_product_id,
          :quantity  => item_quantity,
          :comment   => special_instructions,
          :unit_price => row[column_indices['Material Charge']].to_f / item_quantity,
          :tracking_id => i
        )
      end

      ignored_labels = [
        'Part Number', # Ignored since it's handled specifically above
        '# of Packages',
        '# of Items in Pkgs',
        '# of Items in Design', # Ignored since it's handled specifically above
        'Material Charge', # Ignored since it's handled specifically above
        'Labor Charge',
        'Total Charge'
      ] 

      # Find the item properties for the imported columns, standardizing from any non-standard names
      (labels - ignored_labels).each do |name|
        property = (item && item.properties.find_by_name(name)) || dvinci_custom_properties[name]
        job_item.job_item_properties.create(
          :property_id => property ? property.id : nil,
          :ingest_id => name,
          :value_str => row[label_columns[name]]
        )
      end

      # Attach color information to the item if the item is something that has a color
      # and specifies a color for the color key; if the color key is not known
      # then the value of this property will be nil
      ['Cabinet Color', 'Case Material', 'Case Edge', 'Case Edge 2', 'Door Material', 'Door Edge'].each do |name|
        property = item.nil? ? nil : item.properties.find_by_name(name)
        unless property.nil?
          value = property.property_values.find_by_dvinci_id(color_key)
          unless value.nil?
            job_item.job_item_properties.create(
              :property_id => property.id,
              :ingest_id => color_key,
              :value_str => value.value_str
            )
          end
        end
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
