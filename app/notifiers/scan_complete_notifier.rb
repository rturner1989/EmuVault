# frozen_string_literal: true

class ScanCompleteNotifier < ApplicationNotifier
  notification_methods do
    def message
      found = event.params[:found] || 0
      "Auto-scan found #{found} new #{"game".pluralize(found)} — review and add to your library"
    end
  end
end
