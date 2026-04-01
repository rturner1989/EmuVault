# == Schema Information
#
# Table name: game_saves
#
#  id                  :bigint           not null, primary key
#  checksum            :string
#  saved_at            :datetime
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  emulator_profile_id :bigint
#  game_id             :bigint           not null
#
# Indexes
#
#  index_game_saves_on_emulator_profile_id  (emulator_profile_id)
#  index_game_saves_on_game_id              (game_id)
#
# Foreign Keys
#
#  fk_rails_...  (emulator_profile_id => emulator_profiles.id)
#  fk_rails_...  (game_id => games.id)
#
class GameSave < ApplicationRecord
  include HasFileSizeLimit

  belongs_to :game
  belongs_to :emulator_profile, optional: true

  has_many :sync_events, dependent: :destroy
  has_one_attached :file

  validates :file, presence: true
  max_file_size 100.megabytes

  scope :latest_first, -> { order(created_at: :desc) }

  after_create_commit :notify_new_save, if: -> { Current.user.present? }

  def emulator_label
    return "Unknown emulator" unless emulator_profile

    "#{emulator_profile.name} — #{emulator_profile.platform_label}"
  end

  def file_size_label
    return "—" unless file.attached?

    ActiveSupport::NumberHelper.number_to_human_size(file.byte_size)
  end

  def uploaded_at_label
    created_at.strftime("%b %-d, %Y at %H:%M")
  end

  attr_writer :version_number

  def version_number
    @version_number ||= game.game_saves.where("created_at <= ?", created_at).count
  end

  def download_filename(target_profile = nil)
    profile = target_profile || emulator_profile
    ext = profile&.save_extension || "sav"
    base = if profile
      config = emulator_configs_map[profile.id]
      config&.save_filename.presence || game.default_save_base_name
    else
      game.default_save_base_name
    end
    "#{base}.#{ext}"
  end

  def save_path_hint(target_profile = nil)
    profile = target_profile || emulator_profile
    return nil unless profile&.default_save_path.present?

    dir = profile.default_save_path.chomp("/")
    "#{dir}/#{download_filename(target_profile)}"
  end

  private def notify_new_save
    user = Current.user
    NewSaveNotifier.with(game_save: self).deliver(user)
    count = user.unread_notifications_count
    Turbo::StreamsChannel.broadcast_replace_later_to(
      "notifications_#{user.id}",
      targets: "[data-notification-badge]",
      partial: "shared/notification_badge",
      locals: { count: count }
    )
  end

  private def emulator_configs_map
    @emulator_configs_map ||= game.game_emulator_configs.index_by(&:emulator_profile_id)
  end
end
