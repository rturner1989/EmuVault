class MakeEmulatorProfileOptionalOnGameSaves < ActiveRecord::Migration[8.1]
  def change
    change_column_null :game_saves, :emulator_profile_id, true
  end
end
