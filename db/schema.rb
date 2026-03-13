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

ActiveRecord::Schema[8.1].define(version: 2026_03_13_150000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "emulator_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_save_path"
    t.boolean "is_default", default: false, null: false
    t.string "name", null: false
    t.string "platform", null: false
    t.string "save_extension", null: false
    t.datetime "updated_at", null: false
    t.boolean "user_selected", default: false, null: false
    t.index ["name", "platform"], name: "index_emulator_profiles_on_name_and_platform", unique: true
  end

  create_table "game_emulator_configs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "emulator_profile_id", null: false
    t.bigint "game_id", null: false
    t.string "save_filename", null: false
    t.datetime "updated_at", null: false
    t.index ["emulator_profile_id"], name: "index_game_emulator_configs_on_emulator_profile_id"
    t.index ["game_id", "emulator_profile_id"], name: "index_game_emulator_configs_on_game_id_and_emulator_profile_id", unique: true
    t.index ["game_id"], name: "index_game_emulator_configs_on_game_id"
  end

  create_table "game_saves", force: :cascade do |t|
    t.string "checksum"
    t.datetime "created_at", null: false
    t.bigint "emulator_profile_id"
    t.bigint "game_id", null: false
    t.datetime "saved_at"
    t.datetime "updated_at", null: false
    t.index ["emulator_profile_id"], name: "index_game_saves_on_emulator_profile_id"
    t.index ["game_id"], name: "index_game_saves_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "rom_hash"
    t.string "system", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["rom_hash"], name: "index_games_on_rom_hash"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "sync_events", force: :cascade do |t|
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.bigint "game_save_id", null: false
    t.string "ip_address"
    t.datetime "performed_at", null: false
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.index ["game_save_id"], name: "index_sync_events_on_game_save_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_token"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.boolean "setup_completed", default: false, null: false
    t.datetime "updated_at", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "game_emulator_configs", "emulator_profiles"
  add_foreign_key "game_emulator_configs", "games"
  add_foreign_key "game_saves", "emulator_profiles"
  add_foreign_key "game_saves", "games"
  add_foreign_key "sessions", "users"
  add_foreign_key "sync_events", "game_saves"
end
