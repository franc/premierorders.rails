class CreateJobStateTransitions < ActiveRecord::Migration
  def self.up
    create_table :job_state_transitions do |t|
      t.references :job
      t.references :changed_by
      t.string :prior_status
      t.string :new_status

      t.timestamps
    end
  end

  def self.down
    drop_table :job_state_transitions
  end
end
