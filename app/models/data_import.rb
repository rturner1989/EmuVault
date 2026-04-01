# frozen_string_literal: true

# == Schema Information
#
# Table name: data_imports
#
#  id          :bigint           not null, primary key
#  conflicts   :jsonb
#  manifest    :jsonb
#  resolutions :jsonb
#  result      :jsonb
#  status      :string           default("pending"), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class DataImport < ApplicationRecord
  include HasFileSizeLimit

  enum :status, {
    pending: "pending",
    analyzing: "analyzing",
    conflicts_pending: "conflicts_pending",
    importing: "importing",
    complete: "complete",
    failed: "failed"
  }

  has_one_attached :file
  max_file_size 500.megabytes

  def new_games
    conflict_ids = conflicts.map { |c| c["export_id"] }.to_set
    manifest["games"].reject { |g| conflict_ids.include?(g["export_id"]) }
  end

  def emulator_profiles
    manifest.fetch("emulator_profiles", [])
  end

  def total_saves
    manifest["games"].sum { |g| g["saves"].size }
  end

  def self.analyze_zip(uploaded_file)
    require "zip"

    Zip::File.open(uploaded_file.tempfile.path) do |zip|
      entry = zip.find_entry("manifest.json")
      return [ nil, [] ] unless entry

      manifest = JSON.parse(entry.get_input_stream.read)
      conflicts = manifest["games"].select do |g|
        Game.exists?(title: g["title"], system: g["system"])
      end

      [ manifest, conflicts ]
    end
  rescue => e
    Rails.logger.error "[DataImport] Failed to analyze zip: #{e.message}"
    [ nil, [] ]
  end
end
