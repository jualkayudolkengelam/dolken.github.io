# frozen_string_literal: true

require "yaml"

module CityProfile
  REQUIRED_CITY_KEYS = %w[slug nama_kota tanggal foto_source].freeze
  SLUG_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/.freeze
  TOKEN_KEYS = %w[nama_kota slug tanggal].freeze

  module_function

  def load(path)
    YAML.safe_load(File.read(path), aliases: true) || {}
  end

  def load_defaults
    load(File.expand_path("../data/city-defaults.yml", __dir__))
  end

  def validate_city!(city)
    missing = REQUIRED_CITY_KEYS.reject { |key| city.key?(key) && !city[key].to_s.empty? }
    raise ArgumentError, "missing city fields: #{missing.join(', ')}" unless missing.empty?

    slug = city.fetch("slug").to_s
    raise ArgumentError, "invalid slug: #{slug}" unless SLUG_PATTERN.match?(slug)

    true
  end

  def merge(defaults, city)
    merged = deep_merge(defaults, city["overrides"] || {})
    substitute(merged, city)
  end

  def deep_merge(base, override)
    return override unless base.is_a?(Hash) && override.is_a?(Hash)

    base.merge(override) do |_key, old_value, new_value|
      deep_merge(old_value, new_value)
    end
  end

  def substitute(value, city)
    case value
    when String
      TOKEN_KEYS.reduce(value) do |text, key|
        text.gsub("{{#{key}}}", city.fetch(key).to_s)
      end
    when Hash
      value.transform_values { |nested| substitute(nested, city) }
    when Array
      value.map { |nested| substitute(nested, city) }
    else
      value
    end
  end
end
