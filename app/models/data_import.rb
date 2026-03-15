# frozen_string_literal: true

class DataImport < ApplicationRecord
  extend Enumerize

  enumerize :status, in: %i[pending analyzing conflicts_pending importing complete failed]

  has_one_attached :file
end
