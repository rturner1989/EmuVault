# frozen_string_literal: true

class AddNotificationsCountToNoticedEvents < ActiveRecord::Migration[8.1]
  def change
    add_column :noticed_events, :notifications_count, :integer, default: 0, null: false
  end
end
