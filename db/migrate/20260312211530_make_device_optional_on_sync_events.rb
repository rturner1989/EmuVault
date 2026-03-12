class MakeDeviceOptionalOnSyncEvents < ActiveRecord::Migration[8.1]
  def change
    change_column_null :sync_events, :device_id, true
  end
end
