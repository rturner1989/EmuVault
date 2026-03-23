# frozen_string_literal: true

module HasFileSizeLimit
  extend ActiveSupport::Concern

  class_methods do
    def max_file_size(limit)
      define_method(:file_size_limit) { limit }
      validate :file_size_within_limit
    end
  end

  private def file_size_within_limit
    return unless file.attached? && file.blob.byte_size > file_size_limit

    errors.add(:file, "is too large (max #{ActiveSupport::NumberHelper.number_to_human_size(file_size_limit)})")
  end
end
