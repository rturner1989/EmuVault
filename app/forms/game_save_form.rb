# frozen_string_literal: true

class GameSaveForm < ApplicationForm
  attribute :emulator_profile_id, :integer
  attribute :file

  validates :file, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "GameSave")
  end

  def save(game:, request:)
    return false unless valid?

    game_save = game.game_saves.build(
      emulator_profile_id: emulator_profile_id,
      file: file,
      saved_at: Time.current,
      checksum: compute_checksum
    )

    if game_save.save
      record_sync_event(game_save, request)
      @game_save = game_save
      true
    else
      game_save.errors.each { |error| errors.add(error.attribute, error.message) }
      false
    end
  end

  def game_save
    @game_save
  end

  private def compute_checksum
    return nil unless file.respond_to?(:rewind)

    file.rewind
    Digest::SHA256.hexdigest(file.read)
  end

  private def record_sync_event(game_save, request)
    SyncEvent.create!(
      game_save: game_save,
      action: :push,
      status: :success,
      performed_at: Time.current,
      ip_address: request.remote_ip,
      user_agent: request.user_agent
    )
  end
end
