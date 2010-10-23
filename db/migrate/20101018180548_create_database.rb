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

		create table :roles do |t|
			t.string :name
		end

		create table :user_roles do |t|
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

		create table :address_books do |t|
			t.string :address_type
			t.references :user
			t.references :address
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
			t.references :user
			t.references :franchisee

      t.timestamps
		end

		create_table :franchisee_addresses do |t|
			t.string :address_type
			t.references :franchisee
			t.references :address

      t.timestamps
		end

    create_table :items do |t|
      t.string :name
      t.string :description
			t.string :sku
			t.string :units
			t.string :cutrite_product_prefix

      t.timestamps
    end

    create_table :ivars do |t|
      t.string :name
			t.string :value_type

      t.timestamps
    end

    create_table :ivar_values do |t|
      t.references :ivar
			t.string :cutrite_ref
      t.string :value

      t.timestamps
    end

		create_table :ivar_sets do |t|
			t.string :name

      t.timestamps
		end

		create_table :ivar_set_variables do |t|
			t.references :ivar_set
			t.references :ivar

			t.timestamps
		end

		create_table :item_cutrite_refs do |t|
			t.references :item
			t.string :cutrite_ref
		end

    create_table :jobs do |t|
			t.references :franchisee
			t.int :customer_id
			t.int :shipping_address_id
      t.string :name
      t.string :job_number
      t.int :salesperson_id

      t.timestamps
    end

    create_table :job_items do |t|
			t.references :job
      t.references :item
			t.float :quantity
			t.string :comment

      t.timestamps
    end

    create_table :job_item_ivars do |t|
      t.references :job_item
      t.references :ivar
      t.string :value

      t.timestamps
    end
  end

  def self.down
		drop_table :job_item_ivars
		drop_table :job_items
    drop_table :jobs
    drop_table :item_attribute_values
    drop_table :item_attributes
    drop_table :items
    drop_table :franchisee_contacts
    drop_table :franchisees
    drop_table :address_books
    drop_table :addresses
    drop_table :user_roles
    drop_table :roles
    drop_table :users
  end
end
