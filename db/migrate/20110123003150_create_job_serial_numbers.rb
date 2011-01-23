class CreateJobSerialNumbers < ActiveRecord::Migration
  def self.up
    create_table :job_serial_numbers do |t|
      t.integer :year
      t.integer :max_serial

      t.timestamps
    end
  end

  def self.down
    drop_table :job_serial_numbers
  end
end
