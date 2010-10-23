class JobItemAttribute < ActiveRecord::Base
  belongs_to :job_item
  belongs_to :item_attribute
end
