# frozen_string_literal: true

class UpdateEmulatorProfileUniqueIndexForGameSystem < ActiveRecord::Migration[8.1]
  def change
    remove_index :emulator_profiles, [:name, :platform]
    add_index :emulator_profiles, [:name, :platform, :game_system], unique: true
  end
end
