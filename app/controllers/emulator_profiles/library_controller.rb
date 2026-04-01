module EmulatorProfiles
  class LibraryController < ApplicationController
    def index
      # If systems param present, show the per-system emulator picker
      if params[:systems].present? || params[:system].present?
        load_system_step
        render :show
        return
      end

      @systems = EmulatorProfile.visible_system_options
      @selected_systems = EmulatorProfile.selected_game_systems
      @in_use_systems = Game.systems_in_use
    end

    def show
      load_system_step
      return redirect_to emulator_profiles_library_index_path if @system.blank? # rubocop:disable Style/RedundantReturn
    end

    def create
      selected_ids = Array(params[:profile_ids]).filter_map { |id| id.to_i.nonzero? }
      game_system = params[:game_system]

      EmulatorProfile.update_selections_for_system(game_system, selected_ids: selected_ids) if game_system.present?

      remaining = Array(params[:remaining]).reject(&:blank?)
      previous = Array(params[:previous]).reject(&:blank?) + [ game_system ]
      if remaining.any?
        redirect_to emulator_profiles_library_index_path(system: remaining.first, remaining: remaining.drop(1), previous: previous, total: params[:total])
      else
        load_profiles_list
      end
    end

    private def load_system_step
      if params[:system].present?
        @system = params[:system]
        @remaining = Array(params[:remaining]).reject(&:blank?)
        @previous = Array(params[:previous]).reject(&:blank?)
        @total = params[:total].to_i
      else
        systems = Array(params[:systems]).reject(&:blank?)
        @system = systems.first
        @remaining = systems.drop(1)
        @previous = []
        @total = systems.size
      end

      @current_pos = @previous.size + 1
      @system_label = EmulatorProfile.game_system_label(@system)
      @profiles = EmulatorProfile.defaults_for_system(@system)
      @selected_ids = EmulatorProfile.selected_default_ids_for_system(@system)
      @system_in_use = Game.where(system: @system).exists?
    end

    private def load_profiles_list
      @selected_by_system = EmulatorProfile.selected_by_system
      @in_use_systems = Game.systems_in_use
    end
  end
end
