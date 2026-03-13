# frozen_string_literal: true

class CreateNoticedEvents < ActiveRecord::Migration[8.1]
  def change
    create_table :noticed_events do |t|
      t.string :type
      t.belongs_to :record, polymorphic: true, null: true
      t.jsonb :params, default: {}
      t.timestamps
    end
  end
end
