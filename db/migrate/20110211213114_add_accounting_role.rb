class AddAccountingRole < ActiveRecord::Migration
  def self.up
    execute("insert into roles(name) values ('accounting')")
  end

  def self.down
  end
end
