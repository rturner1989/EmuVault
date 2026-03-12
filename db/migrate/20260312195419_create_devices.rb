class CreateDevices < ActiveRecord::Migration[8.1]
  def change
    create_table :devices do |t|
      t.string :name, null: false
      t.string :device_type, null: false
      t.string :identifier
      t.datetime :last_seen_at

      t.timestamps
    end

    add_index :devices, :identifier, unique: true, where: "identifier IS NOT NULL"
  end
end
