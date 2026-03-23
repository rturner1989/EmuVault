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
  extend Enumerize

  enumerize :status, in: %i[pending analyzing conflicts_pending importing complete failed]

  has_one_attached :file
  max_file_size 500.megabytes
end
