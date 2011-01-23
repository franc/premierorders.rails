class ItemProperty < ActiveRecord::Base
  belongs_to :item, :polymorphic => true
  belongs_to :property
end
