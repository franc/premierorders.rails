require 'json'

class UpdatePropertyCutriteCodes < ActiveRecord::Migration
  def self.execute_sql(array)     
    sql = ActiveRecord::Base.send(:sanitize_sql_array, array)
    execute(sql)
  end

  def self.up
    execute("select id, dvinci_id, module_names, value_str from property_values").each do |row|
      unless row['dvinci_id'].blank?
        value_hash = JSON.parse(row['value_str'])      
        value_hash['dvinci_id'] = row['dvinci_id']

        cutrite_code_rows = execute_sql(["select * from cutrite_codes where dvinci_id = ?", row['dvinci_id']])
        row_selector = lambda do |attr, r|
          r['cutrite_attr'].to_s == attr.to_s # && 
          #(r['name_pattern'].nil? || job_item.item_name =~ /#{r['name_pattern'].gsub(/,/,'|')}/)
        end

        if row['module_names'] == 'Material'
          Option.new(cutrite_code_rows.find{|r| row_selector.call(:material, r)}).each do |crow|
            value_hash['cutrite_code'] = crow['cutrite_code'] 
          end
        end

        if row['module_names'] == 'EdgeBand'
          case value_hash['width'].strip 
            when '19' 
              Option.new(cutrite_code_rows.find{|r| row_selector.call(:edge_band, r)}).each do |crow|
                value_hash['cutrite_code'] = crow['cutrite_code'] 
              end
            when '25'
              Option.new(cutrite_code_rows.find{|r| row_selector.call(:edge_band_2, r)}).each do |crow|
                value_hash['cutrite_code'] = crow['cutrite_code'] 
              end
          end
        end

        execute_sql(['update property_values set value_str = ? where id = ?', value_hash.to_json, row['id']])
      end
    end

    remove_column :property_values, :dvinci_id
  end

  def self.down
  end
end
