# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "../scripts/lib/city_post_schema"
require_relative "../scripts/lib/city_profile"

class CityProfileTest < Minitest::Test
  DATA_DIR = File.expand_path("../scripts/data", __dir__)

  def test_defaults_have_exactly_canonical_fields
    defaults = YAML.safe_load(File.read(File.join(DATA_DIR, "city-defaults.yml")))
    assert_equal CityPostSchema::REQUIRED_FIELDS.sort, defaults.keys.sort
  end

  def test_body_template_uses_city_token
    body = File.read(File.join(DATA_DIR, "city-post-body.md"))
    assert_includes body, "{{nama_kota}}"
    refute_includes body, "Gowa"
  end

  def test_validate_city_accepts_complete_profile
    city = {
      "slug" => "bogor", "nama_kota" => "Bogor",
      "tanggal" => "2026-12-01", "foto_source" => "a.jpeg"
    }
    assert CityProfile.validate_city!(city)
  end

  def test_validate_city_rejects_missing_foto_source
    city = {
      "slug" => "bogor", "nama_kota" => "Bogor", "tanggal" => "2026-12-01"
    }
    assert_raises(ArgumentError) { CityProfile.validate_city!(city) }
  end

  def test_validate_city_rejects_slug_with_spaces
    city = {
      "slug" => "Bogor Utara", "nama_kota" => "Bogor Utara",
      "tanggal" => "2026-12-01", "foto_source" => "a.jpeg"
    }
    assert_raises(ArgumentError) { CityProfile.validate_city!(city) }
  end

  def test_merge_substitutes_tokens_and_applies_overrides
    defaults = {
      "title" => "Jual di {{nama_kota}}",
      "tentang_kota" => { "tagline" => "Tentang {{nama_kota}}", "overview" => "Aman" }
    }
    city = {
      "slug" => "bogor", "nama_kota" => "Bogor",
      "tanggal" => "2026-12-01", "foto_source" => "a.jpeg",
      "overrides" => { "tentang_kota" => { "overview" => "Sejuk" } }
    }
    merged = CityProfile.merge(defaults, city)
    assert_equal "Jual di Bogor", merged["title"]
    assert_equal "Tentang Bogor", merged["tentang_kota"]["tagline"]
    assert_equal "Sejuk", merged["tentang_kota"]["overview"]
  end
end
