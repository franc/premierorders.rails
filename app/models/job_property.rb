require 'property.rb'

class JobProperty < ActiveRecord::Base
  include Properties::Polymorphic
  belongs_to :job
  after_find :morph
end
