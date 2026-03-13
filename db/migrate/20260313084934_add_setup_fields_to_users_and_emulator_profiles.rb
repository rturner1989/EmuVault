class AddSetupFieldsToUsersAndEmulatorProfiles < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :setup_completed, :boolean, default: false, null: false
    add_column :emulator_profiles, :user_selected, :boolean, default: false, null: false
  end
end
