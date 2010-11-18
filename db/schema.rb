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

ActiveRecord::Schema.define(:version => 20101118174336) do

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

# Could not dump table "franchisees" because of following StandardError
#   Unknown type 'credit_status_type' for column 'credit_status'

  create_table "item_attr_options", :force => true do |t|
    t.integer  "item_id",      :null => false
    t.integer  "item_attr_id", :null => false
    t.string   "dvinci_id"
    t.string   "value_str"
    t.boolean  "default"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "item_attrs", :force => true do |t|
    t.string   "name"
    t.string   "value_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

# Could not dump table "items" because of following StandardError
#   Unknown type 'purchase_type' for column 'purchasing'

  create_table "job_item_attributes", :force => true do |t|
    t.integer  "job_item_id",  :null => false
    t.integer  "item_attr_id"
    t.string   "ingest_id"
    t.string   "value_str"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "job_items", :force => true do |t|
    t.integer  "job_id",     :null => false
    t.integer  "item_id"
    t.string   "ingest_id"
    t.float    "quantity"
    t.string   "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "unit_price"
  end

# Could not dump table "jobs" because of following StandardError
#   Unknown type 'status_type' for column 'status'

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
