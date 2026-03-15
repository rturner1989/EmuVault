class CreateDataImports < ActiveRecord::Migration[8.1]
  def change
    create_table :data_imports do |t|
      t.string :status, null: false, default: "pending"
      t.jsonb :manifest
      t.jsonb :conflicts
      t.jsonb :resolutions
      t.jsonb :result

      t.timestamps
    end
  end
end
