class AddLibraryScanSupport < ActiveRecord::Migration[8.1]
  def change
    add_column :emulator_profiles, :game_system, :string

    add_column :users, :scan_enabled, :boolean, default: false, null: false
    add_column :users, :scan_interval, :string, default: "hourly", null: false
    add_column :users, :last_scanned_at, :datetime
    add_column :users, :last_scan_result, :jsonb
  end
end
