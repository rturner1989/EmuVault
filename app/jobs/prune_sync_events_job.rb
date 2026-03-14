# frozen_string_literal: true

class PruneSyncEventsJob < ApplicationJob
  queue_as :default

  def perform
    retention_days = ENV.fetch("ACTIVITY_RETENTION_DAYS", "90").to_i
    cutoff = retention_days.days.ago
    deleted = SyncEvent.where("performed_at < ?", cutoff).delete_all
    Rails.logger.info "[PruneSyncEventsJob] Deleted #{deleted} SyncEvent records older than #{retention_days} days"
  end
end
