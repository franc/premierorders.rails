class AddJobXmlUpload < ActiveRecord::Migration
   def self.up
      add_column :jobs, :davinci_xml_file_name,    :string
      add_column :jobs, :davinci_xml_content_type, :string
      add_column :jobs, :davinci_xml_file_size,    :integer
      add_column :jobs, :davinci_xml_updated_at,   :datetime
    end

    def self.down
      remove_column :jobs, :davinci_xml_file_name
      remove_column :jobs, :davinci_xml_content_type
      remove_column :jobs, :davinci_xml_file_size
      remove_column :jobs, :davinci_xml_updated_at
    end
end
