class FranchiseeAddress < ActiveRecord::Base
	belongs_to :franchisee
	belongs_to :address
end
