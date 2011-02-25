class ProductionBatch < ActiveRecord::Base
  include Cutrite

  has_many :job_items

  STATES = [:open, :closed]

  CUTRITE_BATCH_HEADER = ['', 'Batch Name', '', '', '']

  def to_cutrite_data
    job_lines  = [CUTRITE_BATCH_HEADER, cutrite_batch_data]
    item_lines = [CUTRITE_ITEMS_HEADER] + cutrite_items_data

    (job_lines + item_lines)
  end

  def cutrite_batch_data
    ['', name, '', '', '',].map do |v|
      v.to_s.gsub(/[,'"]/,'')
    end
  end
end
