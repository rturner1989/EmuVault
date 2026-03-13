# == Schema Information
#
# Table name: emulator_profiles
#
#  id                :bigint           not null, primary key
#  default_save_path :string
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
#  index_emulator_profiles_on_name_and_platform  (name,platform) UNIQUE
#
class EmulatorProfile < ApplicationRecord
  extend Enumerize

  enumerize :platform, in: %i[linux windows macos ios android], predicates: true

  has_many :game_saves, dependent: :nullify

  validates :name, presence: true
  validates :platform, presence: true
  validates :save_extension, presence: true
  validates :name, uniqueness: { scope: :platform }

  scope :ordered, -> { order(:name, :platform) }

  def deletable?
    !is_default
  end
end
