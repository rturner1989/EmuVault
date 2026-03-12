class CreateEmulatorProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :emulator_profiles do |t|
      t.string :name, null: false
      t.string :platform, null: false
      t.string :save_extension, null: false
      t.string :default_save_path

      t.timestamps
    end

    add_index :emulator_profiles, %i[name platform], unique: true
  end
end
