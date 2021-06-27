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

ActiveRecord::Schema.define(version: 20201213232312) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",               null: false
    t.string   "title",                 null: false
    t.json     "view",                  null: false
    t.integer  "last_modified_user_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["user_id"], name: "index_bookmarks_on_user_id", using: :btree
  end

  create_table "categories", force: :cascade do |t|
    t.text     "title"
    t.string   "short_title"
    t.text     "description"
    t.string   "url"
    t.integer  "taxonomy_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "draft",                 default: false
    t.integer  "manager_id"
    t.string   "reference"
    t.boolean  "user_only"
    t.integer  "last_modified_user_id"
    t.integer  "parent_id"
    t.date     "date"
    t.index ["draft"], name: "index_categories_on_draft", using: :btree
    t.index ["manager_id"], name: "index_categories_on_manager_id", using: :btree
    t.index ["taxonomy_id"], name: "index_categories_on_taxonomy_id", using: :btree
  end

  create_table "due_dates", force: :cascade do |t|
    t.integer  "indicator_id"
    t.date     "due_date"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "draft",                 default: false
    t.integer  "last_modified_user_id"
    t.index ["draft"], name: "index_due_dates_on_draft", using: :btree
    t.index ["indicator_id"], name: "index_due_dates_on_indicator_id", using: :btree
  end

  create_table "framework_frameworks", force: :cascade do |t|
    t.integer  "framework_id"
    t.integer  "other_framework_id"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
  end

  create_table "framework_taxonomies", force: :cascade do |t|
    t.integer  "framework_id", null: false
    t.integer  "taxonomy_id",  null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["framework_id"], name: "index_framework_taxonomies_on_framework_id", using: :btree
    t.index ["taxonomy_id"], name: "index_framework_taxonomies_on_taxonomy_id", using: :btree
  end

  create_table "frameworks", force: :cascade do |t|
    t.text     "title",          null: false
    t.string   "short_title"
    t.text     "description"
    t.boolean  "has_indicators"
    t.boolean  "has_measures"
    t.boolean  "has_response"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  create_table "indicators", force: :cascade do |t|
    t.text     "title",                                 null: false
    t.text     "description"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "draft",                 default: false
    t.integer  "manager_id"
    t.integer  "frequency_months"
    t.date     "start_date"
    t.boolean  "repeat",                default: false
    t.date     "end_date"
    t.string   "reference"
    t.integer  "last_modified_user_id"
    t.index ["created_at"], name: "index_indicators_on_created_at", using: :btree
    t.index ["draft"], name: "index_indicators_on_draft", using: :btree
    t.index ["manager_id"], name: "index_indicators_on_manager_id", using: :btree
  end

  create_table "measure_categories", force: :cascade do |t|
    t.integer  "measure_id"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "measure_indicators", force: :cascade do |t|
    t.integer  "measure_id"
    t.integer  "indicator_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "measures", force: :cascade do |t|
    t.text     "title",                                 null: false
    t.text     "description"
    t.text     "target_date"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "draft",                 default: false
    t.text     "outcome"
    t.text     "indicator_summary"
    t.text     "target_date_comment"
    t.integer  "last_modified_user_id"
    t.index ["draft"], name: "index_measures_on_draft", using: :btree
  end

  create_table "pages", force: :cascade do |t|
    t.string   "title"
    t.text     "content"
    t.string   "menu_title"
    t.boolean  "draft",                 default: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "order"
    t.integer  "last_modified_user_id"
    t.index ["draft"], name: "index_pages_on_draft", using: :btree
  end

  create_table "progress_reports", force: :cascade do |t|
    t.integer  "indicator_id"
    t.integer  "due_date_id"
    t.text     "title"
    t.text     "description"
    t.string   "document_url"
    t.boolean  "document_public"
    t.boolean  "draft"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "last_modified_user_id"
    t.index ["due_date_id"], name: "index_progress_reports_on_due_date_id", using: :btree
    t.index ["indicator_id"], name: "index_progress_reports_on_indicator_id", using: :btree
  end

  create_table "recommendation_categories", force: :cascade do |t|
    t.integer  "recommendation_id"
    t.integer  "category_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "recommendation_indicators", force: :cascade do |t|
    t.integer  "recommendation_id"
    t.integer  "indicator_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["indicator_id"], name: "index_recommendation_indicators_on_indicator_id", using: :btree
    t.index ["recommendation_id"], name: "index_recommendation_indicators_on_recommendation_id", using: :btree
  end

  create_table "recommendation_measures", force: :cascade do |t|
    t.integer  "recommendation_id"
    t.integer  "measure_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["measure_id"], name: "index_recommendation_measures_on_measure_id", using: :btree
    t.index ["recommendation_id"], name: "index_recommendation_measures_on_recommendation_id", using: :btree
  end

  create_table "recommendation_recommendations", force: :cascade do |t|
    t.integer  "recommendation_id"
    t.integer  "other_recommendation_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "recommendations", force: :cascade do |t|
    t.text     "title",                                 null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "draft",                 default: false
    t.boolean  "accepted"
    t.text     "response"
    t.text     "reference",                             null: false
    t.text     "description"
    t.integer  "last_modified_user_id"
    t.integer  "framework_id"
    t.index ["draft"], name: "index_recommendations_on_draft", using: :btree
    t.index ["framework_id"], name: "index_recommendations_on_framework_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",          null: false
    t.string   "friendly_name", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "sdgtarget_categories", force: :cascade do |t|
    t.integer  "sdgtarget_id"
    t.integer  "category_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "sdgtarget_indicators", force: :cascade do |t|
    t.integer  "sdgtarget_id"
    t.integer  "indicator_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["indicator_id"], name: "index_sdgtarget_indicators_on_indicator_id", using: :btree
    t.index ["sdgtarget_id"], name: "index_sdgtarget_indicators_on_sdgtarget_id", using: :btree
  end

  create_table "sdgtarget_measures", force: :cascade do |t|
    t.integer  "sdgtarget_id"
    t.integer  "measure_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.index ["measure_id"], name: "index_sdgtarget_measures_on_measure_id", using: :btree
    t.index ["sdgtarget_id"], name: "index_sdgtarget_measures_on_sdgtarget_id", using: :btree
  end

  create_table "sdgtarget_recommendations", force: :cascade do |t|
    t.integer  "sdgtarget_id"
    t.integer  "recommendation_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["recommendation_id"], name: "index_sdgtarget_recommendations_on_recommendation_id", using: :btree
    t.index ["sdgtarget_id"], name: "index_sdgtarget_recommendations_on_sdgtarget_id", using: :btree
  end

  create_table "sdgtargets", force: :cascade do |t|
    t.string   "reference"
    t.text     "title"
    t.text     "description"
    t.boolean  "draft",                 default: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.integer  "last_modified_user_id"
    t.index ["draft"], name: "index_sdgtargets_on_draft", using: :btree
  end

  create_table "taxonomies", force: :cascade do |t|
    t.text     "title",                                          null: false
    t.boolean  "tags_measures"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.boolean  "allow_multiple"
    t.boolean  "tags_users"
    t.boolean  "has_manager",                    default: false
    t.integer  "priority"
    t.boolean  "is_smart"
    t.integer  "groups_measures_default"
    t.integer  "groups_recommendations_default"
    t.integer  "groups_sdgtargets_default"
    t.integer  "last_modified_user_id"
    t.integer  "parent_id"
    t.boolean  "has_date"
    t.integer  "framework_id"
    t.index ["framework_id"], name: "index_taxonomies_on_framework_id", using: :btree
  end

  create_table "user_categories", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "category_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "user_roles", force: :cascade do |t|
    t.integer  "user_id",               null: false
    t.integer  "role_id",               null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "last_modified_user_id"
    t.index ["role_id"], name: "index_user_roles_on_role_id", using: :btree
    t.index ["user_id"], name: "index_user_roles_on_user_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",      null: false
    t.string   "encrypted_password",     default: "",      null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,       null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "name"
    t.string   "provider",               default: "email", null: false
    t.string   "uid",                    default: "",      null: false
    t.json     "tokens"
    t.integer  "last_modified_user_id"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree
  end

  add_foreign_key "framework_frameworks", "frameworks"
  add_foreign_key "framework_frameworks", "frameworks", column: "other_framework_id"
  add_foreign_key "framework_taxonomies", "frameworks"
  add_foreign_key "framework_taxonomies", "taxonomies"
  add_foreign_key "recommendation_indicators", "indicators"
  add_foreign_key "recommendation_indicators", "recommendations"
  add_foreign_key "recommendation_recommendations", "recommendations"
  add_foreign_key "recommendation_recommendations", "recommendations", column: "other_recommendation_id"
  add_foreign_key "recommendations", "frameworks"
  add_foreign_key "taxonomies", "frameworks"
end
