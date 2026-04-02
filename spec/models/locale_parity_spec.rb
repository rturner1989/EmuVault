# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Locale parity" do # rubocop:disable RSpec/DescribeClass
  def flatten_keys(hash, prefix = "")
    hash.each_with_object([]) do |(key, value), keys|
      full_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
      if value.is_a?(Hash)
        keys.concat(flatten_keys(value, full_key))
      else
        keys << full_key
      end
    end
  end

  let(:english_keys) do
    en = YAML.load_file(Rails.root.join("config/locales/en.yml"))
    flatten_keys(en["en"]).sort
  end

  %w[fr de es it].each do |locale|
    it "#{locale}.yml has all English keys" do
      path = Rails.root.join("config/locales/#{locale}.yml")
      expect(File.exist?(path)).to be(true), "#{locale}.yml does not exist"

      locale_data = YAML.load_file(path)
      locale_keys = flatten_keys(locale_data[locale]).sort
      missing = english_keys - locale_keys

      expect(missing).to be_empty,
        "#{locale}.yml is missing #{missing.size} key(s):\n  #{missing.first(20).join("\n  ")}"
    end
  end
end
