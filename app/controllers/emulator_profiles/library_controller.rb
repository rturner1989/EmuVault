module EmulatorProfiles
  class LibraryController < ApplicationController
    def index
      authorize! EmulatorProfile, to: :index?

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
      available_systems = EmulatorProfile.where(is_default: true, user_selected: false)
        .distinct
        .pluck(:game_system)
        .compact
        .map(&:to_sym)
      visible_systems = (selected_systems + available_systems).uniq
      @systems = EmulatorProfile.game_system
        .values
        .select { |v| visible_systems.include?(v.value.to_sym) }
      @selected_systems = selected_systems
    end

    def show
      authorize! EmulatorProfile, to: :index?

      load_system_step
      return redirect_to emulator_profiles_library_index_path if @system.blank? # rubocop:disable Style/RedundantReturn
    end

    def create
      authorize! EmulatorProfile, to: :create?

      selected_ids = (params[:profile_ids] || []).map(&:to_i)
      EmulatorProfile.where(id: selected_ids, is_default: true).update_all(user_selected: true)

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
      @system_label = EmulatorProfile.game_system.find_value(@system)&.text || @system.to_s.upcase
      @profiles = EmulatorProfile.where(is_default: true, user_selected: false, game_system: @system).ordered
    end

    private def load_profiles_list
      @selected_by_system = EmulatorProfile.where(user_selected: true)
        .ordered
        .group_by { |p| p.game_system&.to_sym }
    end
  end
end
