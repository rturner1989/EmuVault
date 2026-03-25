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
  include HasGameSystem

  enum :game_system, GAME_SYSTEMS.index_with(&:to_s)

  validates :path, presence: true
  validates :game_system, presence: true

  scope :for_auto_scan, -> { where(auto_scan: true) }
  scope :ordered, -> { order(:game_system, :path) }
end
