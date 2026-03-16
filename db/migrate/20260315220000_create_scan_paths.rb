class CreateScanPaths < ActiveRecord::Migration[8.1]
  def change
    create_table :scan_paths do |t|
      t.string  :path,        null: false
      t.string  :game_system, null: false
      t.boolean :auto_scan,   null: false, default: false
      t.timestamps
    end
  end
end
