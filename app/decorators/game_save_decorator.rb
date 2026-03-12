# frozen_string_literal: true

class GameSaveDecorator < ApplicationDecorator
  def emulator_label
    "#{emulator_profile.name} — #{emulator_profile.platform.text}"
  end

  def slot_label
    slot == 0 ? "Auto / State" : "Slot #{slot}"
  end

  def file_size_label
    return "—" unless file.attached?

    bytes = file.byte_size
    if bytes >= 1_048_576
      format("%.1f MB", bytes.to_f / 1_048_576)
    elsif bytes >= 1_024
      format("%.1f KB", bytes.to_f / 1_024)
    else
      "#{bytes} B"
    end
  end

  def saved_at_label
    saved_at&.strftime("%b %-d, %Y at %H:%M") || "—"
  end

  def download_filename(target_profile = nil)
    profile = target_profile || emulator_profile
    base = object.game.title.gsub(/[^0-9A-Za-z\-_]/, "_")
    "#{base}.#{profile.save_extension}"
  end
end
