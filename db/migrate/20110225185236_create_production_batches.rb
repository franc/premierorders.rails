class CreateProductionBatches < ActiveRecord::Migration
  def self.up
    create_table :production_batches do |t|
      t.string :name
      t.string :batch_no
      t.string :mfg_plant
      t.string :status
      t.text :description
      t.date :closing_date

      t.timestamps
    end

    add_column :job_items, :production_batch_id, :int

    execute('ALTER TABLE job_items ADD FOREIGN KEY (production_batch_id) REFERENCES production_batches')
  end

  def self.down
    remove_column :job_item, :production_batch_id
    drop_table :production_batches
  end
end
