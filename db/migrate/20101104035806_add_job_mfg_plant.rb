class AddJobMfgPlant < ActiveRecord::Migration
  def self.up
    add_column :jobs, :mfg_plant, :string
  end

  def self.down
    remove_column :jobs, :mfg_plant
  end
end
