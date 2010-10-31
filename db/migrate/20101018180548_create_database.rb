class CreateDatabase < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.string :phone2
      t.string :fax
      t.database_authenticatable :null => false
      t.recoverable
      t.rememberable
      t.trackable

      t.timestamps
    end

    add_index :users, :email,                :unique => true
    add_index :users, :reset_password_token, :unique => true

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
      t.string :phone
      t.string :fax
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
			t.references :franchisee, :null => false
			t.references :user, :null => false
			t.string :contact_type

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
			t.string :dvinci_id
			t.string :cutrite_id

      t.timestamps
    end

    create_table :item_attrs do |t|
      t.string :name
			t.string :value_type

      t.timestamps
    end

    create_table :item_attr_options do |t|
      t.references :item, :null => false
      t.references :item_attr, :null => false
			t.string :dvinci_id
      t.string :value_str
      t.boolean :default

      t.timestamps
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
      t.references :item_attr
      t.string :ingest_id
      t.string :value_str

      t.timestamps
    end
  end

  def self.down
    drop_table :job_item_attributes
    drop_table :job_items
    drop_table :jobs
    drop_table :item_attr_options
    drop_table :item_attrs
    drop_table :items
    drop_table :franchisee_addresses
    drop_table :franchisee_contacts
    drop_table :franchisees
    drop_table :address_books
    drop_table :addresses
    drop_table :user_roles
    drop_table :roles
    drop_table :users
  end
end
