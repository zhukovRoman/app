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

ActiveRecord::Schema.define(version: 20140821082855) do

  create_table "apartments", force: true do |t|
    t.string   "out_id",                limit: 500
    t.integer  "floor"
    t.integer  "rooms"
    t.integer  "balcony_сount"
    t.integer  "loggia_сount"
    t.integer  "before_bti_number"
    t.float    "spaces_bti_wo_balcony"
    t.float    "total_plot_area"
    t.float    "space_wo_balcony"
    t.float    "dp_cost"
    t.float    "summ"
    t.float    "finish_summ"
    t.boolean  "is_hypothec"
    t.string   "bank_name"
    t.boolean  "finishing"
    t.string   "realtor",               limit: 500
    t.float    "realtor_fee"
    t.string   "status",                limit: 200
    t.integer  "section_id"
    t.string   "not_sale_date",         limit: 200
    t.string   "free_date",             limit: 200
    t.string   "has_qty_date",          limit: 200
    t.string   "auction_date",          limit: 200
    t.string   "dkp_date",              limit: 200
    t.string   "ps_date",               limit: 200
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buildinggroups", force: true do |t|
    t.string   "out_id",           limit: 500
    t.string   "name",             limit: 500
    t.string   "address",          limit: 1000
    t.string   "start_build_date", limit: 150
    t.string   "end_build_date",   limit: 150
    t.string   "end_sales_date",   limit: 150
    t.float    "square"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "buildings", force: true do |t|
    t.string   "out_id",           limit: 500
    t.string   "name",             limit: 500
    t.string   "address",          limit: 1000
    t.string   "building_type",    limit: 150
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "buildinggroup_id"
  end

  create_table "departments", force: true do |t|
    t.string   "out_number"
    t.string   "name"
    t.integer  "vacancy_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "chief_id"
    t.integer  "parent_id"
    t.integer  "department_type", default: 0
  end

  create_table "employee_stats_departments", force: true do |t|
    t.date     "month"
    t.integer  "department_id"
    t.float    "salary"
    t.float    "bonus"
    t.float    "tax"
    t.float    "avg_salary"
    t.integer  "employee_count"
    t.integer  "vacancy_count"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "manager",        limit: 500
  end

  create_table "employee_stats_months", force: true do |t|
    t.date     "month"
    t.float    "salary"
    t.float    "bonus"
    t.float    "tax"
    t.float    "avg_salary"
    t.float    "salary_manage"
    t.float    "bonus_manage"
    t.float    "tax_manage"
    t.float    "avg_salary_manage"
    t.integer  "employee_count"
    t.integer  "employee_adds"
    t.integer  "employee_dismiss"
    t.integer  "vacancy_count"
    t.integer  "employee_manage_count"
    t.integer  "employee_production_count"
    t.float    "k_dismiss"
    t.float    "k_complect"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "manager_avg_salary"
    t.integer  "AUP_count"
  end

  create_table "employees", force: true do |t|
    t.string   "FIO",           limit: 500
    t.string   "tab_number",    limit: 20
    t.float    "stavka"
    t.string   "post"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "department_id"
    t.integer  "is_delete",                 default: 0
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
    t.float    "NDFL"
    t.float    "insurance"
    t.float    "retention"
  end

  create_table "sections", force: true do |t|
    t.string   "out_id",              limit: 500
    t.integer  "number"
    t.integer  "floors"
    t.integer  "apartments_on_floor"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "building_id"
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

  create_table "vacancies", force: true do |t|
    t.integer  "count"
    t.integer  "department_id"
    t.date     "for_date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
