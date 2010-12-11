class JobProperty < ActiveRecord::Base
  belongs_to :job
  after_find :hydrate

  def hydrate
    property.hydrate(self) unless property.nil?
  end
end
