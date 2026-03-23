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

ActiveRecord::Schema[8.1].define(version: 2026_03_23_130708) do
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

  create_table "data_imports", force: :cascade do |t|
    t.jsonb "conflicts"
    t.datetime "created_at", null: false
    t.jsonb "manifest"
    t.jsonb "resolutions"
    t.jsonb "result"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
  end

  create_table "emulator_profiles", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "default_save_path"
    t.string "game_system"
    t.boolean "is_default", default: false, null: false
    t.string "name", null: false
    t.string "platform", null: false
    t.string "save_extension", null: false
    t.datetime "updated_at", null: false
    t.boolean "user_selected", default: false, null: false
    t.index ["name", "platform", "game_system"], name: "index_emulator_profiles_on_name_and_platform_and_game_system", unique: true
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

  create_table "noticed_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "notifications_count", default: 0, null: false
    t.jsonb "params", default: {}
    t.bigint "record_id"
    t.string "record_type"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id"], name: "index_noticed_events_on_record"
  end

  create_table "noticed_notifications", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "event_id", null: false
    t.datetime "read_at"
    t.bigint "recipient_id", null: false
    t.string "recipient_type", null: false
    t.datetime "seen_at"
    t.string "type"
    t.datetime "updated_at", null: false
    t.index ["event_id"], name: "index_noticed_notifications_on_event_id"
    t.index ["recipient_type", "recipient_id", "read_at"], name: "index_noticed_notifications_on_recipient_and_read_at"
    t.index ["recipient_type", "recipient_id"], name: "index_noticed_notifications_on_recipient"
  end

  create_table "pghero_query_stats", force: :cascade do |t|
    t.bigint "calls"
    t.datetime "captured_at", precision: nil
    t.text "database"
    t.text "query"
    t.bigint "query_hash"
    t.float "total_time"
    t.text "user"
    t.index ["database", "captured_at"], name: "index_pghero_query_stats_on_database_and_captured_at"
  end

  create_table "scan_paths", force: :cascade do |t|
    t.boolean "auto_scan", default: false, null: false
    t.datetime "created_at", null: false
    t.string "game_system", null: false
    t.string "path", null: false
    t.datetime "updated_at", null: false
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
    t.bigint "current_game_id"
    t.string "kuma_url"
    t.jsonb "last_scan_result"
    t.datetime "last_scanned_at"
    t.string "password_digest", null: false
    t.boolean "scan_enabled", default: false, null: false
    t.string "scan_interval", default: "hourly", null: false
    t.boolean "setup_completed", default: false, null: false
    t.string "theme", default: "dracula", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["api_token"], name: "index_users_on_api_token", unique: true
    t.index ["current_game_id"], name: "index_users_on_current_game_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "web_push_subscriptions", force: :cascade do |t|
    t.string "auth", null: false
    t.datetime "created_at", null: false
    t.string "endpoint", null: false
    t.string "p256dh", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["endpoint"], name: "index_web_push_subscriptions_on_endpoint", unique: true
    t.index ["user_id"], name: "index_web_push_subscriptions_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "game_emulator_configs", "emulator_profiles"
  add_foreign_key "game_emulator_configs", "games"
  add_foreign_key "game_saves", "emulator_profiles"
  add_foreign_key "game_saves", "games"
  add_foreign_key "noticed_notifications", "noticed_events", column: "event_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "sync_events", "game_saves"
  add_foreign_key "users", "games", column: "current_game_id", on_delete: :nullify
  add_foreign_key "web_push_subscriptions", "users"
end
