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

ActiveRecord::Schema[7.1].define(version: 2025_12_17_035737) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "properties", force: :cascade do |t|
    t.string "public_id"
    t.string "title"
    t.text "description"
    t.string "property_type"
    t.string "location"
    t.string "region"
    t.string "city"
    t.string "city_area"
    t.string "street"
    t.string "postal_code"
    t.decimal "latitude", precision: 10, scale: 7
    t.decimal "longitude", precision: 10, scale: 7
    t.integer "bedrooms"
    t.integer "bathrooms"
    t.integer "half_bathrooms"
    t.integer "parking_spaces"
    t.float "lot_size"
    t.float "construction_size"
    t.string "title_image_full"
    t.string "title_image_thumb"
    t.jsonb "features", default: []
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "operations", default: []
    t.index ["public_id"], name: "index_properties_on_public_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
