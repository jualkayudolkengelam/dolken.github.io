# frozen_string_literal: true

require "digest"
require "minitest/autorun"
require_relative "../scripts/lib/city_profile"

class PilotCityProfilesTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  PROFILES_PATH = File.join(ROOT, "scripts/data/city-profiles.yml")
  IMAGE_ROOT = File.join(ROOT, "source-image")
  EXPECTED = {
    "tangerang" => "Tangerang",
    "surabaya" => "Surabaya",
    "denpasar" => "Denpasar"
  }.freeze

  def test_pilot_cities_are_complete_and_distinct
    cities = CityProfile.load(PROFILES_PATH).fetch("cities", []).select do |city|
      EXPECTED.key?(city["slug"])
    end
    assert_equal EXPECTED.keys, cities.map { |city| city["slug"] }

    cities.each do |city|
      assert_equal EXPECTED.fetch(city["slug"]), city["nama_kota"]
      assert_equal "2026-11-26", city["tanggal"]
      assert CityProfile.validate_city!(city)
    end

    sources = cities.map { |city| city["foto_source"] }
    assert_equal sources.uniq, sources, "foto_source harus berbeda antar kota"

    hashes = sources.map do |source|
      path = File.expand_path(File.join(IMAGE_ROOT, source))
      assert path.start_with?(IMAGE_ROOT + File::SEPARATOR), "foto_source keluar dari source-image/: #{source}"
      assert File.file?(path), "file sumber tidak ada: #{path}"
      Digest::SHA256.file(path).hexdigest
    end
    assert_equal hashes.uniq, hashes, "hash foto harus berbeda antar kota"
  end
end
