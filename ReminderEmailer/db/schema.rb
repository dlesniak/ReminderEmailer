# encoding: UTF-8
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

ActiveRecord::Schema.define(:version => 20130425172347) do

  create_table "api_keys", :force => true do |t|
    t.string   "access_token"
    t.string   "role"
    t.integer  "User_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "api_keys", ["access_token"], :name => "index_api_keys_on_access_token", :unique => true

  create_table "groups", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.boolean  "private"
  end

  create_table "groups_users", :force => true do |t|
    t.integer "group_id"
    t.integer "user_id"
    t.boolean "admin"
  end

  add_index "groups_users", ["group_id", "user_id"], :name => "index_groups_users_on_group_id_and_user_id"
  add_index "groups_users", ["user_id", "group_id"], :name => "index_groups_users_on_user_id_and_group_id"

  create_table "reminders", :force => true do |t|
    t.string   "title"
    t.boolean  "allDay"
    t.datetime "start"
    t.datetime "end"
    t.integer  "repeat"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "customhtml"
    t.integer  "api_key_id"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
