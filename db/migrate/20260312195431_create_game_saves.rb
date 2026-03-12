class CreateGameSaves < ActiveRecord::Migration[8.1]
  def change
    create_table :game_saves do |t|
      t.references :game, null: false, foreign_key: true
      t.references :emulator_profile, null: false, foreign_key: true
      t.integer :slot, null: false, default: 0
      t.string :checksum
      t.datetime :saved_at

      t.timestamps
    end

    add_index :game_saves, %i[game_id emulator_profile_id slot], unique: true
  end
end
