# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2024_05_05_021300) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.json "view", null: false
    t.integer "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

  create_table "categories", id: :serial, force: :cascade do |t|
    t.text "title"
    t.string "short_title"
    t.text "description"
    t.string "url"
    t.integer "taxonomy_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "draft", default: false
    t.integer "manager_id"
    t.string "reference"
    t.boolean "user_only"
    t.integer "updated_by_id"
    t.integer "parent_id"
    t.date "date"
    t.integer "created_by_id"
    t.index ["draft"], name: "index_categories_on_draft"
    t.index ["manager_id"], name: "index_categories_on_manager_id"
    t.index ["taxonomy_id"], name: "index_categories_on_taxonomy_id"
  end

  create_table "due_dates", id: :serial, force: :cascade do |t|
    t.integer "indicator_id"
    t.date "due_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "draft", default: false
    t.integer "updated_by_id"
    t.integer "created_by_id"
    t.index ["draft"], name: "index_due_dates_on_draft"
    t.index ["indicator_id"], name: "index_due_dates_on_indicator_id"
  end

  create_table "framework_frameworks", id: :serial, force: :cascade do |t|
    t.integer "framework_id"
    t.integer "other_framework_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
  end

  create_table "framework_taxonomies", id: :serial, force: :cascade do |t|
    t.integer "framework_id", null: false
    t.integer "taxonomy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.index ["framework_id"], name: "index_framework_taxonomies_on_framework_id"
    t.index ["taxonomy_id"], name: "index_framework_taxonomies_on_taxonomy_id"
  end

  create_table "frameworks", id: :serial, force: :cascade do |t|
    t.text "title", null: false
    t.string "short_title"
    t.text "description"
    t.boolean "has_indicators"
    t.boolean "has_measures"
    t.boolean "has_response"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
  end

  create_table "indicators", id: :serial, force: :cascade do |t|
    t.text "title", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "draft", default: false
    t.integer "manager_id"
    t.integer "frequency_months"
    t.date "start_date"
    t.boolean "repeat", default: false
    t.date "end_date"
    t.string "reference"
    t.integer "updated_by_id"
    t.integer "created_by_id"
    t.datetime "relationship_updated_at", precision: 6
    t.bigint "relationship_updated_by_id"
    t.index ["created_at"], name: "index_indicators_on_created_at"
    t.index ["draft"], name: "index_indicators_on_draft"
    t.index ["manager_id"], name: "index_indicators_on_manager_id"
    t.index ["reference"], name: "index_indicators_on_reference", unique: true
  end

  create_table "measure_categories", id: :serial, force: :cascade do |t|
    t.integer "measure_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.bigint "updated_by_id"
    t.index ["updated_by_id"], name: "index_measure_categories_on_updated_by_id"
  end

  create_table "measure_indicators", id: :serial, force: :cascade do |t|
    t.integer "measure_id"
    t.integer "indicator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.bigint "updated_by_id"
    t.index ["updated_by_id"], name: "index_measure_indicators_on_updated_by_id"
  end

  create_table "measures", id: :serial, force: :cascade do |t|
    t.text "title", null: false
    t.text "description"
    t.text "target_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "draft", default: false
    t.text "outcome"
    t.text "indicator_summary"
    t.text "target_date_comment"
    t.integer "updated_by_id"
    t.integer "created_by_id"
    t.datetime "relationship_updated_at", precision: 6
    t.bigint "relationship_updated_by_id"
    t.string "reference"
    t.index ["draft"], name: "index_measures_on_draft"
    t.index ["reference"], name: "index_measures_on_reference", unique: true
  end

  create_table "pages", id: :serial, force: :cascade do |t|
    t.string "title"
    t.text "content"
    t.string "menu_title"
    t.boolean "draft", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order"
    t.integer "updated_by_id"
    t.integer "created_by_id"
    t.index ["draft"], name: "index_pages_on_draft"
  end

  create_table "progress_reports", id: :serial, force: :cascade do |t|
    t.integer "indicator_id"
    t.integer "due_date_id"
    t.text "title"
    t.text "description"
    t.string "document_url"
    t.boolean "document_public"
    t.boolean "draft"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id"
    t.integer "created_by_id"
    t.index ["due_date_id"], name: "index_progress_reports_on_due_date_id"
    t.index ["indicator_id"], name: "index_progress_reports_on_indicator_id"
  end

  create_table "recommendation_categories", id: :serial, force: :cascade do |t|
    t.integer "recommendation_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.bigint "updated_by_id"
    t.index ["updated_by_id"], name: "index_recommendation_categories_on_updated_by_id"
  end

  create_table "recommendation_indicators", id: :serial, force: :cascade do |t|
    t.integer "recommendation_id"
    t.integer "indicator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.bigint "updated_by_id"
    t.index ["indicator_id"], name: "index_recommendation_indicators_on_indicator_id"
    t.index ["recommendation_id"], name: "index_recommendation_indicators_on_recommendation_id"
    t.index ["updated_by_id"], name: "index_recommendation_indicators_on_updated_by_id"
  end

  create_table "recommendation_measures", id: :serial, force: :cascade do |t|
    t.integer "recommendation_id"
    t.integer "measure_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.bigint "updated_by_id"
    t.index ["measure_id"], name: "index_recommendation_measures_on_measure_id"
    t.index ["recommendation_id"], name: "index_recommendation_measures_on_recommendation_id"
    t.index ["updated_by_id"], name: "index_recommendation_measures_on_updated_by_id"
  end

  create_table "recommendation_recommendations", id: :serial, force: :cascade do |t|
    t.integer "recommendation_id"
    t.integer "other_recommendation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.bigint "updated_by_id"
    t.index ["updated_by_id"], name: "index_recommendation_recommendations_on_updated_by_id"
  end

  create_table "recommendations", id: :serial, force: :cascade do |t|
    t.text "title", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "draft", default: false
    t.boolean "accepted"
    t.text "response"
    t.text "reference", null: false
    t.text "description"
    t.integer "updated_by_id"
    t.integer "framework_id"
    t.integer "created_by_id"
    t.bigint "relationship_updated_by_id"
    t.datetime "relationship_updated_at", precision: 6
    t.index ["draft"], name: "index_recommendations_on_draft"
    t.index ["framework_id"], name: "index_recommendations_on_framework_id"
    t.index ["reference"], name: "index_recommendations_on_reference", unique: true
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "friendly_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
  end

  create_table "sdgtarget_categories", id: :serial, force: :cascade do |t|
    t.integer "sdgtarget_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
  end

  create_table "sdgtarget_indicators", id: :serial, force: :cascade do |t|
    t.integer "sdgtarget_id"
    t.integer "indicator_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.index ["indicator_id"], name: "index_sdgtarget_indicators_on_indicator_id"
    t.index ["sdgtarget_id"], name: "index_sdgtarget_indicators_on_sdgtarget_id"
  end

  create_table "sdgtarget_measures", id: :serial, force: :cascade do |t|
    t.integer "sdgtarget_id"
    t.integer "measure_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.index ["measure_id"], name: "index_sdgtarget_measures_on_measure_id"
    t.index ["sdgtarget_id"], name: "index_sdgtarget_measures_on_sdgtarget_id"
  end

  create_table "sdgtarget_recommendations", id: :serial, force: :cascade do |t|
    t.integer "sdgtarget_id"
    t.integer "recommendation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.index ["recommendation_id"], name: "index_sdgtarget_recommendations_on_recommendation_id"
    t.index ["sdgtarget_id"], name: "index_sdgtarget_recommendations_on_sdgtarget_id"
  end

  create_table "sdgtargets", id: :serial, force: :cascade do |t|
    t.string "reference"
    t.text "title"
    t.text "description"
    t.boolean "draft", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id"
    t.integer "created_by_id"
    t.index ["draft"], name: "index_sdgtargets_on_draft"
  end

  create_table "taxonomies", id: :serial, force: :cascade do |t|
    t.text "title", null: false
    t.boolean "tags_measures"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "allow_multiple"
    t.boolean "tags_users"
    t.boolean "has_manager", default: false
    t.integer "priority"
    t.boolean "is_smart"
    t.integer "groups_measures_default"
    t.integer "groups_recommendations_default"
    t.integer "groups_sdgtargets_default"
    t.integer "updated_by_id"
    t.integer "parent_id"
    t.boolean "has_date"
    t.integer "framework_id"
    t.integer "created_by_id"
    t.index ["framework_id"], name: "index_taxonomies_on_framework_id"
  end

  create_table "user_categories", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "created_by_id"
    t.bigint "updated_by_id"
    t.index ["updated_by_id"], name: "index_user_categories_on_updated_by_id"
  end

  create_table "user_roles", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "updated_by_id"
    t.integer "created_by_id"
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "provider", default: "email", null: false
    t.string "uid", default: "", null: false
    t.json "tokens"
    t.integer "updated_by_id"
    t.boolean "allow_password_change", default: true
    t.integer "created_by_id"
    t.datetime "relationship_updated_at", precision: 6
    t.bigint "relationship_updated_by_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "framework_frameworks", "frameworks"
  add_foreign_key "framework_frameworks", "frameworks", column: "other_framework_id"
  add_foreign_key "framework_taxonomies", "frameworks"
  add_foreign_key "framework_taxonomies", "taxonomies"
  add_foreign_key "indicators", "users", column: "relationship_updated_by_id"
  add_foreign_key "measure_categories", "users", column: "updated_by_id"
  add_foreign_key "measure_indicators", "users", column: "updated_by_id"
  add_foreign_key "measures", "users", column: "relationship_updated_by_id"
  add_foreign_key "recommendation_categories", "users", column: "updated_by_id"
  add_foreign_key "recommendation_indicators", "indicators"
  add_foreign_key "recommendation_indicators", "recommendations"
  add_foreign_key "recommendation_indicators", "users", column: "updated_by_id"
  add_foreign_key "recommendation_measures", "users", column: "updated_by_id"
  add_foreign_key "recommendation_recommendations", "recommendations"
  add_foreign_key "recommendation_recommendations", "recommendations", column: "other_recommendation_id"
  add_foreign_key "recommendation_recommendations", "users", column: "updated_by_id"
  add_foreign_key "recommendations", "frameworks"
  add_foreign_key "recommendations", "users", column: "relationship_updated_by_id"
  add_foreign_key "taxonomies", "frameworks"
  add_foreign_key "user_categories", "users", column: "updated_by_id"
  add_foreign_key "users", "users", column: "relationship_updated_by_id"
end
