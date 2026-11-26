# frozen_string_literal: true

require "digest"
require "json"
require "minitest/autorun"
require_relative "../scripts/lib/post_timestamps"
require_relative "../scripts/lib/source_image"
require_relative "../scripts/validate-city-post"

class NextCityPostsTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  PROVENANCE = File.join(ROOT, "scripts/data/image-provenance.jsonl")
  CITIES = {
    "banjar" => ["Banjar", "2025-12-19"],
    "batu" => ["Batu", "2026-01-18"],
    "blitar" => ["Blitar", "2026-02-17"],
    "cilegon" => ["Cilegon", "2026-03-20"],
    "cimahi" => ["Cimahi", "2026-04-20"],
    "mojokerto" => ["Mojokerto", "2026-05-24"],
    "pasuruan" => ["Pasuruan", "2026-06-20"],
    "probolinggo" => ["Probolinggo", "2026-07-26"],
    "salatiga" => ["Salatiga", "2026-08-27"],
    "tasikmalaya" => ["Tasikmalaya", "2026-09-22"],
    "tegal" => ["Tegal", "2026-10-24"]
  }.freeze
  FORBIDDEN = /Sungguminasa|Malino|Makassar|Gowa|Sulawesi|Sulsel|在哪里|sakbis|\{\{|\{NAMA_KOTA\}|Pelanggan [0-9]/.freeze

  def test_articles_exist_with_spread_filenames
    dates = CITIES.map do |slug, (_, tanggal)|
      path = article_path(slug, tanggal)
      assert File.file?(path), "artikel tidak ada: #{path}"
      tanggal
    end

    assert_equal dates.uniq, dates, "tanggal nama file harus berbeda"
    assert dates.min >= "2025-11-15", "tanggal terlalu awal"
    assert dates.max <= "2026-11-26", "tanggal melewati hari ini"
    assert_operator dates.map { |date| date[0, 7] }.uniq.size, :>=, 8, "penyebaran bulan terlalu sempit"
  end

  def test_articles_pass_strict_validation
    CITIES.each do |slug, (_, tanggal)|
      result = CityPostValidator.validate_file(article_path(slug, tanggal), root: ROOT, strict: true)
      assert_empty result.errors, "#{slug}: #{result.errors.join('; ')}"
      assert_empty result.warnings, "#{slug}: #{result.warnings.join('; ')}"
    end
  end

  def test_frontmatter_city_and_timestamps
    CITIES.each do |slug, (nama_kota, tanggal)|
      text = File.read(article_path(slug, tanggal))
      data = PostTimestamps.frontmatter(article_path(slug, tanggal))

      assert_includes text, "nama_kota: #{nama_kota}", "#{slug}: nama kota salah"
      refute_match FORBIDDEN, text, "#{slug}: fakta lama atau placeholder tersisa"
      assert_equal "---", text.lines.first&.strip, "#{slug}: penanda frontmatter hilang"
      refute_equal "---", text.lines[1]&.strip, "#{slug}: penanda frontmatter ganda"
      assert_match PostTimestamps::PATTERN, data["date"], "#{slug}: format date salah"
      assert_match PostTimestamps::PATTERN, data["last_modified_at"], "#{slug}: format lastmod salah"
      assert_equal tanggal, PostTimestamps.parse(data["date"]).strftime("%Y-%m-%d"), "#{slug}: tanggal tidak sesuai nama file"
      assert_operator PostTimestamps.parse(data["last_modified_at"]), :>, PostTimestamps.parse(data["date"])
    end
  end

  def test_provenance_matches_sources_and_outputs
    entries = File.readlines(PROVENANCE).map { |line| JSON.parse(line) }

    CITIES.each do |slug, (_, tanggal)|
      output = "/assets/images/posts/jual-kayu-dolken-#{slug}/jual-kayu-dolken-#{slug}-001.webp"
      entry = entries.find { |item| item["slug"] == slug && item["output"] == output }
      refute_nil entry, "provenance tidak ada untuk #{slug}"
      assert_equal tanggal, entry["tanggal"], "#{slug}: tanggal provenance salah"
      assert entry["source"].start_with?("source-image/"), "#{slug}: sumber bukan source-image/"
      source = SourceImage.path(ROOT, entry["source"].sub(%r{\Asource-image/}, ""))
      refute_nil source, "#{slug}: file sumber tidak ada"
      assert_equal Digest::SHA256.file(source).hexdigest, entry["sha256"]
      assert_equal entry["sha256"], entry["source_sha256"]
      assert_equal Digest::SHA256.file(File.join(ROOT, output.sub(%r{\A/}, ""))).hexdigest, entry["output_sha256"]
    end
  end

  private

  def article_path(slug, tanggal)
    File.join(ROOT, "_post_with_city/#{tanggal}-jual-kayu-dolken-#{slug}.md")
  end
end
