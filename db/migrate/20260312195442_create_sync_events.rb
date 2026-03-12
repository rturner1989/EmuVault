class CreateSyncEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :sync_events do |t|
      t.references :game_save, null: false, foreign_key: true
      t.references :device, null: false, foreign_key: true
      t.string :action, null: false
      t.string :status, null: false
      t.datetime :performed_at, null: false

      t.timestamps
    end
  end
end
