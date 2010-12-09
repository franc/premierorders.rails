class JobProperty < ActiveRecord::Base
  belongs_to :job
  belongs_to :property
  after_find :hydrate

  def hydrate
    property.hydrate(self) unless property.nil?
  end
end
