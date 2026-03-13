# frozen_string_literal: true

class GameSaveDecorator < ApplicationDecorator
  def emulator_label
    return "Unknown emulator" unless emulator_profile

    "#{emulator_profile.name} — #{emulator_profile.platform.text}"
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

  def uploaded_at_label
    created_at.strftime("%b %-d, %Y at %H:%M")
  end

  def download_filename(target_profile = nil)
    profile = target_profile || emulator_profile
    ext = profile&.save_extension || "sav"
    base = object.game.title.gsub(/[^0-9A-Za-z\-_ ]/, "").strip.gsub(/\s+/, "_")
    "#{base}.#{ext}"
  end

  # Returns the full suggested path, e.g. ~/.config/retroarch/saves/Pokemon_Emerald.srm
  def save_path_hint(target_profile = nil)
    profile = target_profile || emulator_profile
    return nil unless profile&.default_save_path.present?

    dir = profile.default_save_path.chomp("/")
    "#{dir}/#{download_filename(target_profile)}"
  end
end
