class JobItemAttribute < ActiveRecord::Base
  belongs_to :job_item
  belongs_to :item_attr

  def attr_name
    item_attr.nil? ? ingest_id : item_attr.name
  end
end

