# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20101207180158) do

  create_table "address_books", :force => true do |t|
    t.string  "address_type"
    t.integer "user_id",      :null => false
    t.integer "address_id",   :null => false
  end

  create_table "addresses", :force => true do |t|
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "postal_code"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "franchisee_addresses", :force => true do |t|
    t.integer  "franchisee_id", :null => false
    t.integer  "address_id",    :null => false
    t.string   "address_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "franchisee_contacts", :force => true do |t|
    t.integer  "franchisee_id", :null => false
    t.integer  "user_id",       :null => false
    t.string   "contact_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "franchisees", :force => true do |t|
    t.string   "franchise_name"
    t.string   "phone"
    t.string   "fax"
    t.string   "website"
    t.float    "margin_cabinets"
    t.float    "margin_accessoried"
    t.float    "margin_flooring"
    t.string   "job_number_prefix"
    t.float    "variance_max"
    t.float    "variance_min"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "credit_status",      :limit => 32
  end

  create_table "item_component_properties", :force => true do |t|
    t.integer "item_component_id"
    t.integer "property_id"
    t.string  "qualifier"
  end

  create_table "item_components", :force => true do |t|
    t.integer  "item_id",      :null => false
    t.integer  "component_id"
    t.integer  "quantity"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_item_pricings", :id => false, :force => true do |t|
    t.integer "item_id"
    t.integer "item_pricing_id"
  end

  add_index "item_item_pricings", ["item_id", "item_pricing_id"], :name => "index_item_item_pricings_on_item_id_and_item_pricing_id", :unique => true

  create_table "item_pricings", :force => true do |t|
    t.string   "type"
    t.float    "cost"
    t.string   "pricing_units"
    t.float    "option_cost"
    t.string   "option_pricing_units"
    t.float    "handling_cost"
    t.string   "handling_pricing_units"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_properties", :force => true do |t|
    t.integer "item_id"
    t.integer "property_id"
    t.string  "qualifier"
  end

  create_table "items", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "sku"
    t.string   "units"
    t.string   "dvinci_id"
    t.string   "cutrite_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "purchasing",       :limit => 32
    t.string   "purchase_part_id"
    t.string   "type"
  end

  create_table "job_item_properties", :force => true do |t|
    t.integer  "job_item_id", :null => false
    t.integer  "property_id"
    t.string   "ingest_id"
    t.string   "value_str"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_items", :force => true do |t|
    t.integer  "job_id",      :null => false
    t.integer  "item_id"
    t.string   "ingest_id"
    t.float    "quantity"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "unit_price"
    t.integer  "tracking_id"
  end

  create_table "job_properties", :force => true do |t|
    t.integer  "job_id"
    t.integer  "property_id"
    t.string   "value_str"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.integer  "franchisee_id",                         :null => false
    t.integer  "customer_id"
    t.integer  "shipping_address_id"
    t.string   "name"
    t.string   "job_number"
    t.integer  "salesperson_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "dvinci_xml_file_name"
    t.string   "dvinci_xml_content_type"
    t.integer  "dvinci_xml_file_size"
    t.datetime "dvinci_xml_updated_at"
    t.string   "mfg_plant"
    t.string   "status",                  :limit => 32
    t.date     "due_date"
    t.date     "ship_date"
    t.text     "comment"
  end

  create_table "pricing_property_values", :id => false, :force => true do |t|
    t.integer "item_pricing_id"
    t.integer "property_value_id"
  end

  create_table "properties", :force => true do |t|
    t.string   "name"
    t.string   "module_names"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "family"
  end

  create_table "property_value_selection", :id => false, :force => true do |t|
    t.integer "property_id"
    t.integer "property_value_id"
  end

  create_table "property_values", :force => true do |t|
    t.string   "dvinci_id"
    t.string   "value_str"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "title"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "phone"
    t.string   "phone2"
    t.string   "fax"
    t.string   "email",                               :default => "", :null => false
    t.string   "encrypted_password",   :limit => 128, :default => "", :null => false
    t.string   "password_salt",                       :default => "", :null => false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                       :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
