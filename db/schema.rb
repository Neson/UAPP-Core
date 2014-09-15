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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140910223947) do

  create_table "active_admin_comments", force: true do |t|
    t.string   "namespace"
    t.text     "body"
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"

  create_table "admins", force: true do |t|
    t.string   "username",               default: "", null: false
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.integer  "failed_attempts",        default: 0,  null: false
    t.string   "unlock_token"
    t.datetime "locked_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true
  add_index "admins", ["reset_password_token"], name: "index_admins_on_reset_password_token", unique: true
  add_index "admins", ["unlock_token"], name: "index_admins_on_unlock_token", unique: true
  add_index "admins", ["username"], name: "index_admins_on_username", unique: true

  create_table "colleges", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "departments", force: true do |t|
    t.string   "code"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "college_code"
  end

  create_table "notifications", force: true do |t|
    t.integer  "user_id",                               null: false
    t.string   "title",                                 null: false
    t.text     "content"
    t.string   "image"
    t.string   "type"
    t.string   "sender"
    t.string   "sender_url"
    t.integer  "sender_application_id"
    t.string   "icon"
    t.string   "url"
    t.string   "event_name"
    t.datetime "datetime"
    t.string   "location"
    t.integer  "priority",              default: 3,     null: false
    t.integer  "importance",            default: 3,     null: false
    t.boolean  "dismissed",             default: false, null: false
    t.boolean  "pinned",                default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true

  create_table "oauth_application_data", force: true do |t|
    t.integer  "application_id"
    t.integer  "sms_quota",              default: 0,     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "allow_use_of_user_rfid", default: false, null: false
  end

  create_table "oauth_applications", force: true do |t|
    t.string   "name",         null: false
    t.string   "uid",          null: false
    t.string   "secret",       null: false
    t.text     "redirect_uri", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
  end

  add_index "oauth_applications", ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true

  create_table "settings", force: true do |t|
    t.string   "var",                   null: false
    t.text     "value"
    t.integer  "thing_id"
    t.string   "thing_type", limit: 30
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "settings", ["thing_type", "thing_id", "var"], name: "index_settings_on_thing_type_and_thing_id_and_var", unique: true

  create_table "site_navigations", force: true do |t|
    t.string   "url"
    t.string   "name"
    t.string   "icon"
    t.text     "description"
    t.string   "color"
    t.integer  "priority",           default: 99999, null: false
    t.boolean  "show_in_navigation", default: false, null: false
    t.boolean  "show_in_menu",       default: false, null: false
    t.boolean  "enabled",            default: false, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "cross_domin"
  end

  create_table "user_friendships", force: true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_rfid_data", force: true do |t|
    t.string   "sid",            null: false
    t.string   "encrypted_code", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_rfid_data", ["encrypted_code"], name: "index_user_rfid_data_on_encrypted_code", unique: true
  add_index "user_rfid_data", ["sid"], name: "index_user_rfid_data_on_sid", unique: true

  create_table "users", force: true do |t|
    t.string   "email",                       default: "",    null: false
    t.string   "encrypted_password",          default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",               default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "fbid"
    t.string   "name"
    t.string   "gender"
    t.boolean  "admin",                       default: false
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.string   "student_id"
    t.string   "identity"
    t.integer  "admission_year"
    t.string   "admission_department_code"
    t.string   "department_code"
    t.string   "mobile"
    t.string   "unconfirmed_mobile"
    t.date     "birthday"
    t.string   "address"
    t.text     "brief"
    t.string   "fbtoken"
    t.integer  "email_confirm_tries",         default: 0,     null: false
    t.string   "mobile_confirmation_token"
    t.datetime "mobile_confirmation_sent_at"
    t.integer  "mobile_confirm_tries",        default: 0,     null: false
    t.string   "avatar"
    t.string   "fblink"
    t.string   "fbcover"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
