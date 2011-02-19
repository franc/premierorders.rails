require 'rexml/document'
require 'csv'
require 'json'
require 'item.rb'
require 'property.rb'
require 'util/option'
require 'monoid'

class Job < ActiveRecord::Base
  belongs_to :franchisee, :include => :users
  belongs_to :primary_contact, :class_name => 'User'
  belongs_to :customer, :class_name => 'User'
  belongs_to :placed_by, :class_name => 'User'
  belongs_to :billing_address, :class_name => 'Address'
  belongs_to :shipping_address, :class_name => 'Address'
  has_many   :job_items, :dependent => :destroy
  has_many   :job_properties, :dependent => :destroy, :extend => Properties::Association

  has_attached_file :dvinci_xml

  STATUS_OPTIONS = [
    "Created",
    "Placed",
    "Confirmed",
    "On Hold",
    "Ready For Production",
    "In Production",
    "Ready to Ship",
    "Hold Shipment",
    "Shipped",
    "Cancelled",
  ]

  SHIPMENT_OPTIONS = ["PremierRoute", "LTL", "Drop Ship", "Ground", "2nd Day", "Overnight"]

  def is_manageable_by(user)
    (franchisee && franchisee.users.any?{|u| u.id == user.id}) || 
    primary_contact == user || 
    placed_by == user
  end

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
      when '.xls' then decompose_xml(file)
      when '.csv' then decompose_csv(file)
      else raise "Did not recognize file type for #{File.extname(file.path)}"
    end

    labels, data_rows = rows.partition {|row| row[0] == 'Description'}

    job_properties.create(
      :family => :linear_units,
      :module_names => Property::LinearUnits,
      :value_str => {:linear_units => :in}.to_json
    )

    raise FormatException, "Unexpected number of label rows in document: #{labels.size}; expected 1" unless labels.size == 1
    labels.flatten!

    missing_columns = ['# of Items in Design', 'Description', 'Part Number'] - labels
    raise FormatException, "Did not find required columns in document: #{missing_columns.inspect}" unless missing_columns.empty?

    column_indices = (0...labels.size).zip(labels).inject({}) { |m, l| m[l[1]] = l[0]; m }
    logger.info("Got column index map: #{column_indices.inspect}")

    min_columns = labels.any? {|l| l =~ /Notes/} ? labels.size - 1 : labels.size
    item_rows = data_rows.select do |r| 
      r.size >= min_columns && 
      r[column_indices['Part Number']] && 
      !SKIP_ROWS.any?{|l| r[0].to_s =~ l}
    end

    item_rows.each_with_index do |row, i|
      logger.info "Processing data row: #{row.inspect}"
      dvinci_product_id = row[column_indices['Part Number']]

      # Find the item in the database that corresponds to the dvinci code of the item from the import
      item = Item.find_by_concrete_dvinci_id(dvinci_product_id)

      # Any unlabeled column contents will be appended to the contents of any 'Notes' column to form
      # the special instructions.
      unlabeled_col_values = ((0...row.size).to_a - column_indices.values).map{|i| row[i]}
      special_instructions = if column_indices['Notes'] 
        (unlabeled_col_values << row[column_indices['Notes']]).join("; ")
      else
        unlabeled_col_values.join("; ")
      end

      item_quantity = row[column_indices['# of Items in Design']].to_i
      unit_price    = row[column_indices['Material Charge']].gsub(/\$/,'').strip.to_f / item_quantity
      job_item_config = {
          :ingest_id => dvinci_product_id,
          :ingest_desc => row[column_indices['Description']],
          :quantity  => item_quantity,
          :comment   => special_instructions,
          :unit_price => unit_price,
          :tracking_id => i + 1
      }

      # Add the item reference to the job item, if an item is known
      item.each{|i| job_item_config[:item_id] = i.id}

      job_item = job_items.create(job_item_config)

      # Read the cut dimensions from the input and add to the job item as dimension properties
      dimensions = {
        Property::Height => Option.fromString(row[column_indices['Cut Height']]),
        Property::Width => Option.fromString(row[column_indices['Cut Width']]),
        Property::Depth => Option.fromString(row[column_indices['Cut Depth']])
      }

      job_item.job_item_properties.create(
        :family => :dimensions,
        :module_names => dimensions.inject([]){|m, pair| pair[1].map{|v| m << pair[0]}.orSome(m)}.
                         map{|m| m.to_s.demodulize}.join(","),
        :value_str => dimensions.inject({:linear_units => :in}) {|m, pair| 
           pair[1].each{|v| m[pair[0].to_s.demodulize.downcase.to_sym] = v}
           m
         }.to_json
      )

      # Match the color code to a color option for the item and add a color property to the job item.
      item.each do |i|
        product_code_matchdata = dvinci_product_id.match(/(\d{3})\.(\w{3})\.(\w{3})\.(\w{3})\.(\d{2})(\w)/)
        if product_code_matchdata
          color_code = product_code_matchdata.captures[3]
          logger.info("Searching for color #{color_code} in #{i.color_opts.inspect}")
          Option.new(i.color_opts.detect{|opt| opt.dvinci_id.strip[1..2] == color_code[1..2]}).each do |opt|
            job_item.job_item_properties.create(
              :family => Property::Color::DESCRIPTOR.family,
              :module_names => Property::Color::DESCRIPTOR.module_names,
              :value_str => {:color => opt.color}.to_json
            )    
          end
        end
      end
    end
  end

  def place_order(date, current_user)
    if self.placement_date.nil?
      transaction do 
        serial_no = JobSerialNumber.find_by_year(date.year) || JobSerialNumber.new(:year => date.year, :max_serial => 2000)
        serial_no.max_serial += 1
        self.status = 'Placed' 
        self.job_number = "SO-#{serial_no.max_serial}"
        self.placement_date = date 
        self.placed_by = current_user
        logger.info( self.inspect)
        serial_no.save
      end
    end
    logger.info( self.inspect)
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
    job_items.order('tracking_id').select{|job_item| job_item.item && job_item.item.cutrite_id && !job_item.item.cutrite_id.strip.empty?}.map{|job_item| cutrite_item_data(job_item)}
  end

  def job_items_total(&item_test)
    job_items.select{|i| item_test.call(i)}.inject(0.0) do |total, job_item|
      total + job_item.compute_total.bind{|t| t.right.toOption}.orSome(job_item.unit_price * job_item.quantity)
    end
  end

  def inventory_items_total
    @inventory_items_total ||= component_inventory_hardware.inject(job_items_total{|i| i.inventory?}) do |total, hardware_item|
      total + hardware_item.compute_total.bind{|t| t.right.toOption}.orSome(0.0)
    end

    @inventory_items_total
  end

  def non_inventory_items_total
    @non_inventory_items_total ||= job_items_total{|i| !(i.inventory? || i.buyout?)}
    @non_inventory_items_total
  end

  def buyout_items_total
    @buyout_items_total ||= job_items_total{|i| i.buyout?}
    @buyout_items_total
  end

  def total 
    non_inventory_items_total + buyout_items_total
  end

  def component_inventory_hardware
    hardware_query = HardwareQuery.new do |item|
      item.purchasing == 'Inventory'
    end

    aggregated = job_items.inject({}) do |m, job_item|
      m.merge(job_item.inventory_hardware) do |k, h1, h2|
        h1 + h2
      end
    end

    aggregated.values
  end

  def inventory_items
    @inventory_items ||= job_items.order('tracking_id').select{|i| i.inventory?} + component_inventory_hardware
    @inventory_items
  end

  def to_s
    "#{Job.model_name.human} #{name}"
  end

  private

  def cutrite_item_data(job_item)
    basic_attr_values = [
      job_item.quantity.to_i,
      job_item.comment,
      job_item.width.orSome(''),
      job_item.height.orSome(''),
      job_item.depth.orSome(''),
      job_item.item.nil? ? '' : job_item.item.cutrite_id,
      job_item.item_name      
    ]

    panel_query = ColorQuery.new('panel_material', job_item.dvinci_color_code) {|v| v.thickness(:in) != 0.25}
    panel_material = Option.new(job_item.item).bind {|i| i.query(panel_query, [])}

    eb_query = ColorQuery.new('edge_band', job_item.dvinci_color_code) {|v| v.width == 19 }
    eb_material = Option.new(job_item.item).bind {|i| i.query(eb_query, [])}

    eb2_query = ColorQuery.new('edge_band', job_item.dvinci_color_code) {|v| v.width == 25 }
    eb2_material = Option.new(job_item.item).bind {|i| i.query(eb2_query, [])}

    custom_attr_values = [
      panel_material.map{|m| m.color}.orSome(''),
      panel_material.map{|m| m.cutrite_code}.orSome(''),
      eb_material.map{|m| m.cutrite_code}.orSome(''),
      eb2_material.map{|m| m.cutrite_code}.orSome(''),
      panel_material.map{|m| m.cutrite_code}.orSome(''),
      eb_material.map{|m| m.cutrite_code}.orSome('')
    ]

    basic_attr_values + custom_attr_values
  end
end

class ColorQuery < ItemQuery
  def initialize(property_family, dvinci_color_code, &value_test)
    super(Monoid::UNIQ)
    @property_family = property_family
    @dvinci_color_code = dvinci_color_code
    @value_test = value_test
  end  

  def query_property(property)
    pv = Option.iif(property.family == @property_family) do
      property.property_values.detect do |v|
        v.respond_to?(:dvinci_id) && 
        v.dvinci_id == @dvinci_color_code &&
        (@value_test.nil? || @value_test.call(v))
      end
    end
  end
end

class FormatException < RuntimeError
  attr :message
  def initialize(message)
    @message = message
  end
end
