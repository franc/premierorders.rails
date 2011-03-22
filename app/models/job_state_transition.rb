class JobStateTransition < ActiveRecord::Base
  belongs_to :job
  belongs_to :changed_by, :class_name => 'User'
end
