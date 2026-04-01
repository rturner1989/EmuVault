# == Schema Information
#
# Table name: emulator_profiles
#
#  id                :bigint           not null, primary key
#  default_save_path :string
#  game_system       :string
#  is_default        :boolean          default(FALSE), not null
#  name              :string           not null
#  platform          :string           not null
#  save_extension    :string           not null
#  user_selected     :boolean          default(FALSE), not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#
# Indexes
#
#  index_emulator_profiles_on_name_and_platform_and_game_system  (name,platform,game_system) UNIQUE
#
class EmulatorProfile < ApplicationRecord
  include HasGameSystem

  PLATFORM_LABELS = {
    linux: "Linux",
    windows: "Windows",
    macos: "macOS",
    ios: "iOS",
    android: "Android"
  }.freeze

  enum :platform, {
    linux: "linux",
    windows: "windows",
    macos: "macos",
    ios: "ios",
    android: "android"
  }
  enum :game_system, GAME_SYSTEMS.index_with(&:to_s)

  has_many :game_saves, dependent: :nullify
  has_many :game_emulator_configs, dependent: :destroy

  validates :name, presence: true
  validates :platform, presence: true
  validates :game_system, presence: true
  validates :save_extension, presence: true
  validates :name, uniqueness: { scope: [ :platform, :game_system ] }

  scope :ordered, -> { order(:game_system, :name, :platform) }
  scope :for_system, ->(system) { where(game_system: system) }
  scope :user_selected, -> { where(user_selected: true) }
  scope :defaults, -> { where(is_default: true) }
  scope :selected_for_system, ->(system) { user_selected.for_system(system) }
  scope :defaults_for_system, ->(system) { defaults.for_system(system).ordered }

  def self.selected_game_systems
    user_selected.distinct.pluck(:game_system).compact.map(&:to_sym)
  end

  def self.default_game_systems
    defaults.distinct.pluck(:game_system).compact.map(&:to_sym)
  end

  def self.selected_default_ids_for_system(system)
    selected_for_system(system).defaults.pluck(:id).to_set
  end

  def self.selected_by_system
    user_selected.ordered.group_by { |profile| profile.game_system&.to_sym }
  end

  def self.update_selections_for_system(game_system, selected_ids: [])
    defaults_for_system(game_system).update_all(user_selected: false)
    if selected_ids.any?
      defaults_for_system(game_system)
        .where(id: selected_ids)
        .update_all(user_selected: true)
    end
  end

  def self.visible_system_options
    systems = (selected_game_systems + default_game_systems).uniq
    systems.map { |s| { value: s.to_s, text: game_system_label(s) } }.sort_by { |s| s[:text] }
  end

  def platform_label
    PLATFORM_LABELS[platform&.to_sym] || platform.to_s.capitalize
  end

  def deletable?
    !is_default
  end

  def in_use?
    game_system.present? && Game.where(system: game_system).exists?
  end
end
