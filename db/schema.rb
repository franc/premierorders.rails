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

ActiveRecord::Schema.define(:version => 20110225185236) do

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

  create_table "cutrite_codes", :id => false, :force => true do |t|
    t.string "cutrite_attr", :limit => 32
    t.string "dvinci_id",    :limit => 8
    t.string "color",        :limit => 32
    t.string "cutrite_code", :limit => 32
    t.string "name_pattern", :limit => 32
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
    t.decimal  "margin_cabinets",                  :precision => 8, :scale => 2
    t.decimal  "margin_accessories",               :precision => 8, :scale => 2
    t.decimal  "margin_flooring",                  :precision => 8, :scale => 2
    t.string   "job_number_prefix"
    t.decimal  "variance_max",                     :precision => 8, :scale => 2
    t.decimal  "variance_min",                     :precision => 8, :scale => 2
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "credit_status",      :limit => 32
    t.text     "notes"
  end

  create_table "item_component_properties", :force => true do |t|
    t.integer "item_component_id"
    t.integer "property_id"
    t.string  "qualifier"
  end

  create_table "item_components", :force => true do |t|
    t.integer  "item_id",       :null => false
    t.integer  "component_id"
    t.integer  "quantity"
    t.string   "type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "context_names"
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
    t.string   "purchasing",        :limit => 32
    t.string   "purchase_part_id"
    t.string   "type"
    t.decimal  "base_price",                      :precision => 8, :scale => 2
    t.string   "vendor"
    t.float    "weight"
    t.decimal  "install_cost",                    :precision => 8, :scale => 2
    t.float    "rebate_factor"
    t.float    "retail_multiplier"
  end

  create_table "job_item_properties", :force => true do |t|
    t.integer  "job_item_id",  :null => false
    t.string   "ingest_id"
    t.string   "family"
    t.string   "qualifier"
    t.string   "module_names"
    t.string   "value_str"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_items", :force => true do |t|
    t.integer  "job_id",                                            :null => false
    t.integer  "item_id"
    t.string   "ingest_id"
    t.float    "quantity"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "unit_price",          :precision => 8, :scale => 2
    t.integer  "tracking_id"
    t.string   "ingest_desc"
    t.decimal  "override_price",      :precision => 8, :scale => 2
    t.integer  "production_batch_id"
  end

  create_table "job_properties", :force => true do |t|
    t.integer  "job_id"
    t.string   "family"
    t.string   "qualifier"
    t.string   "module_names"
    t.string   "value_str"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_serial_numbers", :force => true do |t|
    t.integer  "year"
    t.integer  "max_serial"
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
    t.datetime "placement_date"
    t.integer  "placed_by_id"
    t.string   "tracking_number"
    t.string   "ship_method"
    t.integer  "primary_contact_id"
    t.text     "notes"
    t.integer  "billing_address_id"
  end

  create_table "production_batches", :force => true do |t|
    t.string   "name"
    t.string   "batch_no"
    t.string   "mfg_plant"
    t.string   "status"
    t.text     "description"
    t.date     "closing_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "properties", :force => true do |t|
    t.string   "name"
    t.string   "family"
    t.string   "module_names"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "property_value_selection", :id => false, :force => true do |t|
    t.integer "property_id"
    t.integer "property_value_id"
  end

  create_table "property_values", :force => true do |t|
    t.string   "name"
    t.string   "module_names"
    t.string   "value_str"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string "name"
  end

  create_table "user_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
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
