class RemoveSlotFromGameSavesAddIsDefaultToEmulatorProfiles < ActiveRecord::Migration[8.1]
  def change
    # Remove slot and the unique index that included it
    remove_index :game_saves, [:game_id, :emulator_profile_id, :slot], if_exists: true
    remove_column :game_saves, :slot, :integer

    # Add is_default to protect seeded profiles from deletion
    add_column :emulator_profiles, :is_default, :boolean, default: false, null: false
  end
end
