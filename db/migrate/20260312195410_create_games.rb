class CreateGames < ActiveRecord::Migration[8.1]
  def change
    create_table :games do |t|
      t.string :title, null: false
      t.string :system, null: false
      t.string :rom_hash

      t.timestamps
    end

    add_index :games, :rom_hash
  end
end
