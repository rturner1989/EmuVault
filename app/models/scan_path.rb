# == Schema Information
#
# Table name: scan_paths
#
#  id          :bigint           not null, primary key
#  auto_scan   :boolean          default(FALSE), not null
#  game_system :string           not null
#  path        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class ScanPath < ApplicationRecord
  extend Enumerize

  enumerize :game_system, in: %i[
    nes snes gb gbc gba nds
    genesis sms gg
    psx ps2 psp
    n64 gc wii
    arcade
  ]

  validates :path, presence: true
  validates :game_system, presence: true

  scope :for_auto_scan, -> { where(auto_scan: true) }
  scope :ordered, -> { order(:game_system, :path) }
end
