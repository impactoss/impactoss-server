class DropSdgtargetTables < ActiveRecord::Migration[6.1]
  def up
    drop_table :sdgtarget_categories
    drop_table :sdgtarget_indicators
    drop_table :sdgtarget_measures
    drop_table :sdgtarget_recommendations
    drop_table :sdgtargets
  end

  def down
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
  end
end
