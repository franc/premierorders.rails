require 'rexml/document'

class Job < ActiveRecord::Base
	belongs_to :franchisee
	belongs_to :primary_contact, :class_name => 'User'
	belongs_to :customer, :class_name => 'User'
	belongs_to :billing_address, :class_name => 'Address'
	belongs_to :shipping_address, :class_name => 'Address'
	has_many :job_items

  has_attached_file :davinci_xml

  DAVINCI_CUSTOM_ATTRIBUTES = {
		'Cut Width' => 'width',
		'Cut Height' => 'height',
		'Cut Depth' => 'depth'
	}

  CUTRITE_BASIC_ATTRIBUTES = ['qty', 'comment', 'width', 'height', 'depth']

	CUTRITE_CUSTOM_ATTRIBUTES = [
    'CutRite Product ID',
    'Cabinet Color',
    'Case Material',
    'Case Edge',
    'Case Edge 2',
    'Door Material',
    'Door Edge',
    'Shipping Method',
    'Weight'
  ]

	def job_contact
		primary_contact || franchisee.primary_contact
	end

	def ship_to
		shipping_address || franchisee.shipping_address
	end

	def add_items_from_davinci(xml)
		doc = REXML::Document.new(xml)
		rows = doc.get_elements("//Row").inject([]) do |rows, row_element|
      rows << row_element.get_elements("Cell/Data").map{|cell| cell.text}
		end

    labels, data_rows = rows.partition do |row|
      row[0] == 'Description'
    end

    raise "Unexpected number of label rows in XML document: #{labels.size}; expected 1" unless labels.size == 1
    labels.flatten!

		label_columns = (0...labels.size).zip(labels).inject({}) { |m, l| m[l[1]] = l[0]; m }

		data_rows.select{|r| r.size == label_columns.size}.each do |row|
      logger.info "Processing data row: #{row.inspect}"
      davinci_product_id = row[label_columns['Part Number']]
			product_code_matchdata = davinci_product_id.match(/(\d{3})\.(\d{3})\.(\d{3})\.(\d{3})\.(\d{3})/)
      item = if product_code_matchdata
        t1, t2, t3, color_key, t5 = product_code_matchdata.captures
        Item.find_by_davinci_id("#{t1}.#{t2}.#{t3}.x.#{t5}")
      else 
        nil
      end

      job_item = if (item.nil?)
        job_items.create(
          :ingest_id => davinci_product_id,
          :quantity  => row[label_columns['# of Items in Design']],
          :comment   => row[label_columns['Description']]
        )
      else
        job_items.create(
          :item      => item,
          :ingest_id => davinci_product_id,
          :quantity  => row[label_columns['# of Items in Design']],
          :comment   => row[label_columns['Description']]
        )
      end

      # Find the item attributes for the imported columns, standardizing from any non-standard names
      attribute_labels = labels - ['Part Number', '# of Items in Design', 'Description']
      attributes = item.nil? ? {} : attribute_labels.inject({}) do |attr_map, name|
        attr = item.attributes.find_by_name(DAVINCI_CUSTOM_ATTRIBUTES[name] || name)
        attr_map[name] = attr unless attr.nil?
        attr_map
      end

      attribute_labels.each do |name|
        if attributes.has_key?(name)
          # for attributes where the attribute is already known in relation to the item,
          # reference it when creating the job attribute
          job_item.job_item_attributes.create(
            :attribute => attributes[name],
            :ingest_id => name,
            :value_str => row[label_columns[name]]
          )
        else
          # otherwise, just attach the information as an opaque key/value pair
          job_item.job_item_attributes.create(
            :ingest_id => name,
            :value_str => row[label_columns[name]]
          )
        end
      end

      # Attach color information to the item if the item is something that has a color
      # and specifies a color for the color key; if the color key is not known
      # then the value of this attribute will be nil
      ['Cabinet Color', 'Case Material', 'Case Edge', 'Case Edge 2', 'Door Material', 'Door Edge'].each do |name|
        attr = item.nil? ? nil : item.attributes.find_by_name(name)
        if !attr.nil?
          job_item.job_item_attributes.create(
            :attribute => attr,
            :ingest_id => color_key,
            :value_str => attr.find_attribute_option_by_cutrite_ref(color_key)
          )
        end
      end
    end
	end

	def to_cutrite_csv
		job_lines  = [cutrite_job_header,     to_csv_line(cutrite_job_data)]
		item_lines = [cutrite_items_header] + (job_items.map{|item| to_csv_line(cutrite_item_data(job_item))})

		(job_lines + item_lines).join("\n")
	end

	private

	def to_csv_line(arr)
		arr.map{|l| l.gsub(/,/, ' ')}.join(",")
	end

	def cutrite_job_header
		",Job Name,,,,Account Name,Shipping Address,Shipping City Shipping State Shipping Postal Code,Phone,Fax"
	end

	def cutrite_job_data
		[
			'',
			job_name,
			'', '', '',
			franchisee.franchise_name,
			shipping_address.address1 + (shipping_address.address2 || ''),
			"#{ship_to.city} #{ship_to.state} #{ship_to.postal_code}",
			job_contact.phone,
			job_contact.fax
		]
	end

	def cutrite_items_header
    to_csv_line(CUTRITE_BASIC_ATTRIBUTES + CUTRITE_CUSTOM_ATTRIBUTES)
	end

	def cutrite_item_data(job_item)
		basic_attr_values = [
      job_item.quantity,
      job_item.comment,
      job_item['width'],
      job_item['height'],
      job_item['depth']
    ]

		custom_attr_values = cutrite_custom_attributes.map { |name| job_item[name] }

		basic_attr_values + custom_attr_values
	end
end
