class JobItemProperty < ActiveRecord::Base
  belongs_to :job_item
  belongs_to :property
  after_find :enrich

  def hydrate
    property.hydrate(self) unless property.nil?
  end

  def name
    property.nil? ? ingest_id : property.name
  end
end

