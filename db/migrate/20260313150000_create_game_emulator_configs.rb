# frozen_string_literal: true

class CreateGameEmulatorConfigs < ActiveRecord::Migration[8.1]
  def change
    create_table :game_emulator_configs do |t|
      t.references :game, null: false, foreign_key: true
      t.references :emulator_profile, null: false, foreign_key: true
      t.string :save_filename, null: false

      t.timestamps
    end

    add_index :game_emulator_configs, %i[game_id emulator_profile_id], unique: true
  end
end
