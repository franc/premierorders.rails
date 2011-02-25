module ProductionBatchesHelper
  def open_batch_options(selected)
    opts = if selected.forall{|id| id == -1}
      ProductionBatch.find_all_by_status(:open).map{|batch| [batch.name, batch.id]}
    else
      [['(multiple)', -1]] + ProductionBatch.find_all_by_status(:open).map {|batch| [batch.name, batch.id]}
    end 

    logger.info("Selected production batch is #{selected.inspect}")

    options_for_select(opts, selected.orSome(nil))
  end
end
