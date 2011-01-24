class AddIngestDescriptionToJobItem < ActiveRecord::Migration
  def self.up
    add_column :job_items, :ingest_desc, :string
  end

  def self.down
    remove_column :job_items, :ingest_desc
  end
end
