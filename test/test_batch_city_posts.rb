# frozen_string_literal: true

require "digest"
require "json"
require "minitest/autorun"
require_relative "../scripts/validate-city-post"

class BatchCityPostsTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  DATE = "2026-11-26"
  PROVENANCE = File.join(ROOT, "scripts/data/image-provenance.jsonl")
  CITIES = {
    "jakarta-pusat" => "Jakarta Pusat",
    "jakarta-selatan" => "Jakarta Selatan",
    "jakarta-barat" => "Jakarta Barat",
    "jakarta-timur" => "Jakarta Timur",
    "serang" => "Serang",
    "bogor" => "Bogor",
    "depok" => "Depok",
    "bekasi" => "Bekasi",
    "tangerang-selatan" => "Tangerang Selatan",
    "sukabumi" => "Sukabumi",
    "cirebon" => "Cirebon",
    "solo" => "Solo",
    "magelang" => "Magelang",
    "pekalongan" => "Pekalongan",
    "malang" => "Malang",
    "kediri" => "Kediri",
    "madiun" => "Madiun"
  }.freeze
  FORBIDDEN = /Sungguminasa|Malino|Makassar|Gowa|Sulawesi|Sulsel|在哪里|sakbis|\{\{|\{NAMA_KOTA\}/.freeze

  def test_batch_articles_exist
    CITIES.each_key do |slug|
      assert File.file?(article_path(slug)), "artikel tidak ada: #{article_path(slug)}"
    end
  end

  def test_batch_articles_pass_strict_validation
    CITIES.each_key do |slug|
      result = CityPostValidator.validate_file(article_path(slug), root: ROOT, strict: true)
      assert_empty result.errors, "#{slug}: #{result.errors.join('; ')}"
      assert_empty result.warnings, "#{slug}: #{result.warnings.join('; ')}"
    end
  end

  def test_batch_articles_have_correct_city_and_no_legacy_facts
    CITIES.each do |slug, nama_kota|
      text = File.read(article_path(slug))
      assert_includes text, "nama_kota: #{nama_kota}", "#{slug}: nama kota salah"
      refute_match FORBIDDEN, text, "#{slug}: fakta lama atau placeholder tersisa"
      assert_equal "---", text.lines.first&.strip, "#{slug}: penanda frontmatter hilang"
      refute_equal "---", text.lines[1]&.strip, "#{slug}: penanda frontmatter ganda"
    end
  end

  def test_provenance_matches_sources_and_outputs
    entries = File.readlines(PROVENANCE).map { |line| JSON.parse(line) }

    CITIES.each_key do |slug|
      output = "/assets/images/posts/jual-kayu-dolken-#{slug}/jual-kayu-dolken-#{slug}-001.webp"
      entry = entries.find { |item| item["slug"] == slug && item["output"] == output }
      refute_nil entry, "provenance tidak ada untuk #{slug}"
      assert_equal DATE, entry["tanggal"], "tanggal provenance salah: #{slug}"

      source = File.join(ROOT, entry["source"])
      assert entry["source"].start_with?("source-image/"), "#{slug}: sumber bukan source-image/"
      assert File.file?(source), "#{slug}: file sumber tidak ada"
      assert_equal Digest::SHA256.file(source).hexdigest, entry["sha256"], "#{slug}: sha256 sumber salah"
      assert_equal entry["sha256"], entry["source_sha256"], "#{slug}: source_sha256 tidak konsisten"

      webp = File.join(ROOT, output.sub(%r{\A/}, ""))
      assert File.file?(webp), "#{slug}: WebP tidak ada"
      assert_equal Digest::SHA256.file(webp).hexdigest, entry["output_sha256"], "#{slug}: sha256 output salah"
    end

    outputs = CITIES.keys.map do |slug|
      entries.find { |item| item["slug"] == slug }["output_sha256"]
    end
    assert_equal outputs.uniq, outputs, "hash WebP harus berbeda antar kota"
  end

  private

  def article_path(slug)
    File.join(ROOT, "_post_with_city/#{DATE}-jual-kayu-dolken-#{slug}.md")
  end
end
