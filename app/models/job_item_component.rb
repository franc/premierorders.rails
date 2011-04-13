require 'fp'

class JobItemComponent < ActiveRecord::Base
  belongs_to :job_item
  belongs_to :item

  def unit_price
    if !cost_calc_err.blank?
      Either.left(cost_calc_err)
    else
      Either.right(read_attribute(:unit_cost))
    end
  end

  def quantity
    if !qty_calc_err.blank?
      Either.left(qty_calc_err)
    else
      Either.right(read_attribute(:quantity))
    end
  end
end
