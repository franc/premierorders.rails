class CreateDatabase < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :title
      t.string :email
      t.string :phone
      t.string :fax

      t.timestamps
    end

		create_table :roles do |t|
			t.string :name
		end

		create_table :user_roles do |t|
			t.references :user
			t.references :role

      t.timestamps
		end

    create_table :addresses do |t|
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :postal_code
      t.string :country

      t.timestamps
    end

		create_table :address_books do |t|
			t.string :address_type
			t.references :user, :null => false
			t.references :address, :null => false
		end

    create_table :franchisees do |t|
			t.string :franchise_name
			t.string :website
      t.float  :margin_cabinets
      t.float  :margin_accessoried
      t.float  :margin_flooring
      t.string :job_number_prefix
      t.float  :variance_max
      t.float  :variance_min

      t.timestamps
    end

		create_table :franchisee_contacts do |t|
			t.string :contact_type
			t.references :franchisee, :null => false
			t.references :user, :null => false

      t.timestamps
		end

		create_table :franchisee_addresses do |t|
			t.references :franchisee, :null => false
			t.references :address, :null => false
			t.string :address_type

      t.timestamps
		end

    create_table :items do |t|
      t.string :name
      t.string :description
			t.string :sku
			t.string :units
			t.string :cutrite_id

      t.timestamps
    end

    create_table :attribute do |t|
      t.string :name
			t.string :value_type

      t.timestamps
    end

    create_table :attribute_options do |t|
      t.references :attribute
			t.string :cutrite_ref
      t.string :value_str

      t.timestamps
    end

    create_table :items_attributes do |t|
      t.references :item, :null => false
      t.references :attribute, :null => false
    end

		create_table :item_cutrite_refs do |t|
			t.references :item, :null => false
			t.string :cutrite_ref
		end

    create_table :jobs do |t|
			t.references :franchisee, :null => false
			t.integer :customer_id
			t.integer :shipping_address_id
      t.string :name
      t.string :job_number
      t.integer :salesperson_id

      t.timestamps
    end

    create_table :job_items do |t|
			t.references :job, :null => false
      t.references :item
      t.string :ingest_id
			t.float :quantity
			t.string :comment

      t.timestamps
    end

    create_table :job_item_attributes do |t|
      t.references :job_item, :null => false
      t.references :attribute
      t.string :ingest_key
      t.string :value_str

      t.timestamps
    end
  end

  def self.down
    drop_table :job_item_attributes
    drop_table :job_items
    drop_table :jobs
    drop_table :item_cutrite_refs
    drop_table :items_attributes
    drop_table :attribute_options
    drop_table :attribute
    drop_table :items
    drop_table :franchisee_addresses
    drop_table :franchisee_contacts
    drop_table :franchisees
    drop table :address_books
    drop_table :addresses
    drop table :user_roles
    drop table :roles
    drop_table :users
  end
end
