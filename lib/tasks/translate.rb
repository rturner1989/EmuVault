#!/usr/bin/env ruby
# frozen_string_literal: true

require "yaml"
require "digest"
require "open3"

LOCALES_DIR = File.expand_path("../../config/locales", __dir__)
EN_FILE = File.join(LOCALES_DIR, "en.yml")
CHECKSUMS_FILE = File.join(LOCALES_DIR, ".en_checksums.yml")
TARGET_LOCALES = %w[fr de es it].freeze
LANGUAGE_NAMES = { "fr" => "French", "de" => "German", "es" => "Spanish", "it" => "Italian" }.freeze

def flatten_keys(hash, prefix = "")
  hash.each_with_object({}) do |(key, value), result|
    full_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
    if value.is_a?(Hash)
      result.merge!(flatten_keys(value, full_key))
    else
      result[full_key] = value.to_s
    end
  end
end

def unflatten_keys(hash)
  result = {}
  hash.each do |key, value|
    parts = key.split(".")
    current = result
    parts[0..-2].each do |part|
      current[part] ||= {}
      current = current[part]
    end
    current[parts.last] = value
  end
  result
end

def compute_checksums(flat_hash)
  flat_hash.transform_values { |v| Digest::SHA256.hexdigest(v) }
end

def load_checksums
  return {} unless File.exist?(CHECKSUMS_FILE)

  YAML.load_file(CHECKSUMS_FILE) || {}
end

def save_checksums(checksums)
  File.write(CHECKSUMS_FILE, checksums.to_yaml)
end

def find_changed_keys(current_checksums, stored_checksums)
  current_checksums.each_with_object([]) do |(key, checksum), changed|
    changed << key if stored_checksums[key] != checksum
  end
end

def load_locale_file(locale)
  path = File.join(LOCALES_DIR, "#{locale}.yml")
  return {} unless File.exist?(path)

  data = YAML.load_file(path)
  data&.dig(locale) ? flatten_keys(data[locale]) : {}
end

def save_locale_file(locale, flat_hash)
  nested = unflatten_keys(flat_hash)
  path = File.join(LOCALES_DIR, "#{locale}.yml")
  File.write(path, { locale => nested }.to_yaml)
end

def translate_keys(keys_to_translate, english_flat, target_locale)
  return {} if keys_to_translate.empty?

  pairs = keys_to_translate.map { |k| "#{k}: #{english_flat[k].inspect}" }.join("\n")
  language = LANGUAGE_NAMES[target_locale]

  prompt = <<~PROMPT
    Translate these English UI strings to #{language} for a gaming save file manager app called EmuVault.
    Keep translations concise — they appear in buttons, labels, and short messages.
    Preserve all %{variable} placeholders exactly as-is.
    For pluralisation keys (ending in .one or .other), translate both forms appropriately for #{language}.
    Game system names (NES, SNES, PlayStation, etc.) and platform names (Linux, macOS, iOS, Android) should NOT be translated.
    Output ONLY valid YAML (no code fences, no explanation), with each key on its own line as:
    key: "translated value"

    #{pairs}
  PROMPT

  stdout, stderr, status = Open3.capture3("claude", "--print", "-p", prompt)

  unless status.success?
    warn "  Error translating to #{language}: #{stderr}"
    return {}
  end

  parse_translation_output(stdout)
end

def parse_translation_output(output)
  text = output.strip

  # Remove code fences if present
  text = $1 if text =~ /```(?:ya?ml)?\n(.*?)```/m

  result = {}
  text.each_line do |line|
    line = line.strip
    next if line.empty? || line.start_with?("#")

    if line =~ /\A([\w.]+):\s*"(.*)"\s*\z/
      result[$1] = $2
    elsif line =~ /\A([\w.]+):\s*(.*)\s*\z/
      result[$1] = $2
    end
  end
  result
end

# --- Main ---

force = ARGV.include?("--force")

english = YAML.load_file(EN_FILE)
english_flat = flatten_keys(english["en"])
current_checksums = compute_checksums(english_flat)
stored_checksums = force ? {} : load_checksums

changed_keys = find_changed_keys(current_checksums, stored_checksums)

if changed_keys.empty?
  puts "No changes detected in English locale file."
  exit 0
end

puts "Found #{changed_keys.size} new/changed key(s)"

TARGET_LOCALES.each do |locale|
  existing = load_locale_file(locale)
  keys_needed = changed_keys.reject { |k| existing.key?(k) && !force }

  if keys_needed.empty?
    puts "  #{locale}: up to date"
    next
  end

  puts "  #{locale}: translating #{keys_needed.size} key(s)..."
  translations = translate_keys(keys_needed, english_flat, locale)

  translations.each do |key, value|
    existing[key] = value
  end

  save_locale_file(locale, existing)
  puts "  #{locale}: done (#{translations.size} translated)"
end

save_checksums(current_checksums)
puts "Checksums updated."
