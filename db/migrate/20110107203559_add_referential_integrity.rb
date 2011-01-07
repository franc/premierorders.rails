class AddReferentialIntegrity < ActiveRecord::Migration
  def self.up
    execute("delete from item_properties where item_id not in (select id from items)")
    execute("delete from item_components where item_id not in (select id from items)")
    execute("delete from item_components where component_id not in (select id from items)")
    execute("delete from item_component_properties where item_component_id not in (select id from item_components)")
    execute("delete from job_items where job_id not in (select id from jobs)")
    execute("delete from job_item_properties where job_item_id not in (select id from job_items)")
    execute("delete from job_properties where job_id not in (select id from jobs)")

    execute("ALTER TABLE address_books ADD FOREIGN KEY (user_id) REFERENCES users")
    execute("ALTER TABLE address_books ADD FOREIGN KEY (address_id) REFERENCES addresses")
    execute("ALTER TABLE franchisee_addresses ADD FOREIGN KEY (franchisee_id) REFERENCES franchisees")
    execute("ALTER TABLE franchisee_addresses ADD FOREIGN KEY (address_id) REFERENCES addresses")
    execute("ALTER TABLE franchisee_contacts ADD FOREIGN KEY (franchisee_id) REFERENCES franchisees")
    execute("ALTER TABLE franchisee_contacts ADD FOREIGN KEY (user_id) REFERENCES users")
    execute("ALTER TABLE item_component_properties ADD FOREIGN KEY (item_component_id) REFERENCES item_components")
    execute("ALTER TABLE item_component_properties ADD FOREIGN KEY (property_id) REFERENCES properties")
    execute("ALTER TABLE item_components ADD FOREIGN KEY (item_id) REFERENCES items")
    execute("ALTER TABLE item_components ADD FOREIGN KEY (component_id) REFERENCES items")
    execute("ALTER TABLE item_properties ADD FOREIGN KEY (item_id) REFERENCES items")
    execute("ALTER TABLE item_properties ADD FOREIGN KEY (property_id) REFERENCES properties")
    execute("ALTER TABLE job_item_properties ADD FOREIGN KEY (job_item_id) REFERENCES job_items")
    execute("ALTER TABLE job_items ADD FOREIGN KEY (job_id) REFERENCES jobs")
    execute("ALTER TABLE job_items ADD FOREIGN KEY (item_id) REFERENCES items")
    execute("ALTER TABLE job_properties ADD FOREIGN KEY (job_id) REFERENCES jobs")
    execute("ALTER TABLE jobs ADD FOREIGN KEY (franchisee_id) REFERENCES franchisees")
    execute("ALTER TABLE jobs ADD FOREIGN KEY (customer_id) REFERENCES users")
    execute("ALTER TABLE jobs ADD FOREIGN KEY (salesperson_id) REFERENCES users")
    execute("ALTER TABLE jobs ADD FOREIGN KEY (shipping_address_id) REFERENCES addresses")
    execute("ALTER TABLE property_value_selection ADD FOREIGN KEY (property_id) REFERENCES properties")
    execute("ALTER TABLE property_value_selection ADD FOREIGN KEY (property_value_id) REFERENCES property_values")
    execute("ALTER TABLE user_roles ADD FOREIGN KEY (user_id) REFERENCES users")
    execute("ALTER TABLE user_roles ADD FOREIGN KEY (role_id) REFERENCES roles")
  end

  def self.down
  end
end
