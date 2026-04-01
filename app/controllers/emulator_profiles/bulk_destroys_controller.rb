module EmulatorProfiles
  class BulkDestroysController < ApplicationController
    def create
      ids = Array(params[:profile_ids]).map(&:to_i)
      profiles = EmulatorProfile.where(id: ids)

      removed = 0
      deselected = 0
      skipped = 0

      profiles.each do |profile|
        if profile.in_use?
          skipped += 1
        elsif profile.deletable?
          profile.destroy ? removed += 1 : skipped += 1
        else
          profile.update!(user_selected: false)
          deselected += 1
        end
      end

      @bulk_notice = build_bulk_notice(removed, deselected, skipped)
      @selected_by_system = EmulatorProfile.selected_by_system
      @in_use_systems = Game.systems_in_use
    end

    private def build_bulk_notice(removed, deselected, skipped)
      parts = []
      parts << "#{removed} #{"profile".pluralize(removed)} removed" if removed > 0
      parts << "#{deselected} #{"profile".pluralize(deselected)} deselected" if deselected > 0
      parts << "#{skipped} skipped (in use by games)" if skipped > 0
      parts.join(", ").capitalize + "."
    end
  end
end
