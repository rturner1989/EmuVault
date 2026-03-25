module EmulatorProfiles
  class LibraryController < ApplicationController
    def index
      # If systems param present, show the per-system emulator picker
      if params[:systems].present? || params[:system].present?
        load_system_step
        render :show
        return
      end

      selected_systems = EmulatorProfile.where(user_selected: true)
        .distinct
        .pluck(:game_system)
        .compact
        .map(&:to_sym)
      available_systems = EmulatorProfile.where(is_default: true)
        .distinct
        .pluck(:game_system)
        .compact
        .map(&:to_sym)
      visible_systems = (selected_systems + available_systems).uniq
      @systems = visible_systems
        .map { |s| { value: s.to_s, text: EmulatorProfile.game_system_label(s) } }
        .sort_by { |s| s[:text] }
      @selected_systems = selected_systems
    end

    def show
      load_system_step
      return redirect_to emulator_profiles_library_index_path if @system.blank? # rubocop:disable Style/RedundantReturn
    end

    def create
      selected_ids = Array(params[:profile_ids]).filter_map { |id| id.to_i.nonzero? }
      game_system = params[:game_system]

      if game_system.present?
        EmulatorProfile.where(is_default: true, game_system: game_system).update_all(user_selected: false)
        EmulatorProfile.where(id: selected_ids, is_default: true).update_all(user_selected: true) if selected_ids.any?
      end

      remaining = Array(params[:remaining]).reject(&:blank?)
      if remaining.any?
        redirect_to emulator_profiles_library_index_path(system: remaining.first, remaining: remaining.drop(1), total: params[:total])
      else
        load_profiles_list
      end
    end

    private def load_system_step
      if params[:system].present?
        @system = params[:system]
        @remaining = Array(params[:remaining]).reject(&:blank?)
        @total = params[:total].to_i
      else
        systems = Array(params[:systems]).reject(&:blank?)
        @system = systems.first
        @remaining = systems.drop(1)
        @total = systems.size
      end

      @current_pos = @total - @remaining.size
      @system_label = EmulatorProfile.game_system_label(@system)
      @profiles = EmulatorProfile.where(is_default: true, game_system: @system).ordered
      @selected_ids = EmulatorProfile.where(is_default: true, user_selected: true, game_system: @system).pluck(:id).to_set
    end

    private def load_profiles_list
      @selected_by_system = EmulatorProfile.where(user_selected: true)
        .ordered
        .group_by { |p| p.game_system&.to_sym }
    end
  end
end
