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

ActiveRecord::Schema.define(version: 20140615125736) do

  create_table "departments", force: true do |t|
    t.string   "out_number"
    t.string   "name"
    t.integer  "vacancy_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chief_id"
    t.integer  "parent_id"
  end

  create_table "employees", force: true do |t|
    t.string   "FIO",           limit: 500
    t.string   "tab_number",    limit: 20
    t.float    "stavka"
    t.string   "post"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "department_id"
  end

  create_table "personal_flows", force: true do |t|
    t.string   "operation_type"
    t.string   "new_post"
    t.string   "old_post"
    t.date     "flow_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "employee_id"
    t.integer  "old_department_id"
    t.integer  "new_department_id"
  end

  create_table "salaries", force: true do |t|
    t.float    "salary"
    t.float    "bonus"
    t.float    "tax"
    t.date     "salary_date"
    t.float    "add_salary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "employee_id"
  end

  create_table "users", force: true do |t|
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
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
