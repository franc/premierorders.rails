class FranchiseeContact < ActiveRecord::Base
	belongs_to :franchisee
	belongs_to :user
end

