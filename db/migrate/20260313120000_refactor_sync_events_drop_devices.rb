class RefactorSyncEventsDropDevices < ActiveRecord::Migration[8.1]
  def change
    add_column :sync_events, :ip_address, :string
    add_column :sync_events, :user_agent, :string

    remove_foreign_key :sync_events, :devices
    remove_column :sync_events, :device_id, :bigint

    drop_table :devices do |t|
      t.string :name, null: false
      t.string :device_type, null: false
      t.string :identifier
      t.datetime :last_seen_at
      t.timestamps
    end
  end
end
