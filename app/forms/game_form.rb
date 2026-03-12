# frozen_string_literal: true

class GameForm < ApplicationForm
  attribute :title, :string
  attribute :system, :string
  attribute :rom_hash, :string

  validates :title, presence: true
  validates :system, presence: true

  def self.model_name
    ActiveModel::Name.new(self, nil, "Game")
  end
end
