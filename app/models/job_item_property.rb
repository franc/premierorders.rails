require 'property.rb'

class JobItemProperty < ActiveRecord::Base
  include Properties::Polymorphic
  belongs_to :job_item
  after_find :morph
end

