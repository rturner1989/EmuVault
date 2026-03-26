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
  scope :selected_for_system, ->(system) { where(user_selected: true, game_system: system) }

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
