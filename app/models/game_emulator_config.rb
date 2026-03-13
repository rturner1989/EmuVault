# frozen_string_literal: true

# == Schema Information
#
# Table name: game_emulator_configs
#
#  id                  :bigint           not null, primary key
#  save_filename       :string           not null
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  emulator_profile_id :bigint           not null
#  game_id             :bigint           not null
#
# Indexes
#
#  index_game_emulator_configs_on_emulator_profile_id              (emulator_profile_id)
#  index_game_emulator_configs_on_game_id                          (game_id)
#  index_game_emulator_configs_on_game_id_and_emulator_profile_id  (game_id,emulator_profile_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (emulator_profile_id => emulator_profiles.id)
#  fk_rails_...  (game_id => games.id)
#
class GameEmulatorConfig < ApplicationRecord
  belongs_to :game
  belongs_to :emulator_profile

  validates :save_filename, presence: true
  validates :emulator_profile, uniqueness: { scope: :game }
end
