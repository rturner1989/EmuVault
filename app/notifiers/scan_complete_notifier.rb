# frozen_string_literal: true

class ScanCompleteNotifier < ApplicationNotifier
  notification_methods do
    def message
      added = event.params[:added] || 0
      "Auto-scan found #{added} new #{"game".pluralize(added)}"
    end
  end
end
