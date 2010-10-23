require 'rexml/document'

class Job < ActiveRecord::Base
	belongs_to :franchisee
	belongs_to :primary_contact, :class_name => 'User'
	belongs_to :customer, :class_name => 'User'
	belongs_to :billing_address, :class_name => 'Address'
	belongs_to :shipping_address, :class_name => 'Address'
	has_many :job_items

  DAVINCI_CUSTOM_ATTRIBUTES = [
		'Part Number' => 'CutRite Product ID',
		'Cut Width' => 'width',
		'Cut Height' => 'height',
		'Cut Depth' => 'depth'
	]

	def job_contact
		primary_contact || franchisee.primary_contact
	end

	def ship_to
		shipping_address || franchisee.shipping_address
	end

	def add_itemsfrom_davinci(xml)
		doc = REXML::Document.new(xml)
		labels = doc.elements["//Row[@ss:StyleID='s30']/Cell/Data"].map{|d| d.text}
		label_columns = (0...labels.size).zip(labels).inject({}) { |m, l| m[l[1]] = l[0]; m }
		rows = doc.elements["//Row"].inject([]) do |m, row|
			if row.attributes['ss:StyleID'] != 's30'
				m << row.elements["Cell/Data"].map{|cell| cell.text}
			end
		end

		rows.each do |row|
			cutrite_product_id = row[label_columns['Part Number']]
			item = Item.find_by_cutrite_product_prefix(cutrite_product_id[/\d/])
		end
	end

	def to_cutrite_csv
		lines = [
			cutrite_job_header,
			to_csv_line(cutrite_job_data),
			cutrite_items_header
		]

		lines += job_items.map{|item| cutrite_item_line(item)}
		lines.join("\n")
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
		['qty', 'comment', 'width', 'height', 'depth'] + cutrite_custom_attributes
	end

	def cutrite_custom_attributes
		[
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
	end

	def cutrite_item_line(item)
		columns = [item.design_qty, item.comment, item.attr_value('Cut Width'), item.attr_value('Cut Height'), item.attr_value('Cut Depth')] +
							cutrite_custom_attributes.map{|name| item.attr_value(name)}

		to_csv_line(columns)
	end
end
