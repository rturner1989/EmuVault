# frozen_string_literal: true

class CreateNoticedNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :noticed_notifications do |t|
      t.string :type
      t.belongs_to :event, null: false, foreign_key: { to_table: :noticed_events }
      t.belongs_to :recipient, polymorphic: true, null: false
      t.datetime :read_at
      t.datetime :seen_at
      t.timestamps
    end

    add_index :noticed_notifications, %i[recipient_type recipient_id read_at], name: "index_noticed_notifications_on_recipient_and_read_at"
  end
end
