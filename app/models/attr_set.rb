class AttrSet < ActiveRecord::Base
  has_and_belongs_to_many :items
  has_and_belongs_to_many :item_attrs, :join_table => "attr_set_members"
end
