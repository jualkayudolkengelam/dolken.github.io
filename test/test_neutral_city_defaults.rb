# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "../scripts/lib/city_profile"
require_relative "../scripts/lib/city_post_schema"

class NeutralCityDefaultsTest < Minitest::Test
  DEFAULTS = CityProfile.load_defaults.freeze
  FORBIDDEN = [
    "Sungguminasa", "Malino", "Makassar", "Gowa", "Sulawesi", "Sulsel",
    "Somba Opu", "Pallangga", "Bajeng", "Bontonompo", "Tinggimoncong",
    "Biringbulu", "Balla Lompoa", "Katangka", "Pisang Epe", "Hasanuddin"
  ].freeze

  def test_defaults_have_no_legacy_city_facts
    serialized = YAML.dump(DEFAULTS)

    FORBIDDEN.each do |term|
      refute_match Regexp.new(Regexp.escape(term), Regexp::IGNORECASE), serialized,
                   "default masih memuat fakta lama: #{term}"
    end
    refute_match(/在哪里|sakbis/, serialized)
    refute_match(/18 kecamatan|1\.883 km|765\.000|167 kelurahan|13 kecamatan/, serialized)
  end

  def test_defaults_have_no_template_instructions
    (DEFAULTS["finalisasi_pengiriman"] || {}).each_value do |value|
      refute_match(/\A(?:tulis|jelaskan|mention)\b/i, value.to_s)
    end
  end

  def test_testimonials_use_indonesian_names
    %w[testimoni_residential testimoni_komersial].each do |key|
      names = Array(DEFAULTS[key]).map { |entry| entry["nama"].to_s }
      refute_empty names, "#{key} tidak memiliki testimoni"
      names.each do |name|
        refute_match(/\APelanggan(?: Komersial)? \d+\z/, name, "#{key}: nama masih generik: #{name}")
        refute_match(/\d/, name, "#{key}: nama tidak boleh mengandung angka: #{name}")
      end
    end
  end

  def test_substituted_defaults_have_no_placeholders
    merged = CityProfile.merge(DEFAULTS,
                               "slug" => "tangerang",
                               "nama_kota" => "Tangerang",
                               "tanggal" => "2026-11-26",
                               "foto_source" => "x.jpeg")

    assert_empty CityPostSchema.placeholders(merged)
  end
end
