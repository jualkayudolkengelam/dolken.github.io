# frozen_string_literal: true

require "date"
require "digest"
require "json"
require "minitest/autorun"
require_relative "../scripts/lib/post_timestamps"
require_relative "../scripts/lib/source_image"
require_relative "../scripts/validate-city-post"

class MoreCityPostsTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  PROVENANCE = File.join(ROOT, "scripts/data/image-provenance.jsonl")
  MANIFEST = <<~MANIFEST.freeze
    kepulauan-seribu|Kepulauan Seribu|2025-11-26|source-image/WhatsApp Image 2026-11-26 at 11.45.20.jpeg
    kabupaten-bandung-barat|Kabupaten Bandung Barat|2025-12-04|source-image/WhatsApp Unknown 2026-11-26 at 13.33.49/WhatsApp Image 2026-10-17 at 17.10.05.jpeg
    kabupaten-cianjur|Kabupaten Cianjur|2025-12-18|source-image/WhatsApp Unknown 2026-11-26 at 13.33.49/WhatsApp Image 2026-10-17 at 17.10.20.jpeg
    kabupaten-purwakarta|Kabupaten Purwakarta|2025-12-24|source-image/WhatsApp Unknown 2026-11-26 at 13.33.49/WhatsApp Image 2026-10-17 at 17.10.28.jpeg
    kabupaten-subang|Kabupaten Subang|2025-12-31|source-image/WhatsApp Unknown 2026-11-26 at 13.33.49/WhatsApp Image 2026-10-17 at 17.10.34.jpeg
    kabupaten-garut|Kabupaten Garut|2026-01-14|source-image/WhatsApp Unknown 2026-11-26 at 13.33.49/WhatsApp Image 2026-10-17 at 17.10.52.jpeg
    kabupaten-ciamis|Kabupaten Ciamis|2026-01-20|source-image/WhatsApp Unknown 2026-11-26 at 13.33.49/WhatsApp Image 2026-10-17 at 17.10.58.jpeg
    kabupaten-kuningan|Kabupaten Kuningan|2026-02-02|source-image/WhatsApp Unknown 2026-11-26 at 13.33.49/WhatsApp Image 2026-10-17 at 17.11.05.jpeg
    kabupaten-pangandaran|Kabupaten Pangandaran|2026-02-15|source-image/WhatsApp Unknown 2026-11-26 at 13.33.49/WhatsApp Image 2026-10-17 at 17.11.12.jpeg
    kabupaten-lebak|Kabupaten Lebak|2026-02-24|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.25 (1).jpeg
    kabupaten-pandeglang|Kabupaten Pandeglang|2026-03-02|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.25.jpeg
    kabupaten-boyolali|Kabupaten Boyolali|2026-03-13|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.26 (1).jpeg
    kabupaten-klaten|Kabupaten Klaten|2026-03-25|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.26 (2).jpeg
    kabupaten-sukoharjo|Kabupaten Sukoharjo|2026-04-01|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.26.jpeg
    kabupaten-wonogiri|Kabupaten Wonogiri|2026-04-11|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.27 (1).jpeg
    kabupaten-karanganyar|Kabupaten Karanganyar|2026-04-25|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.27 (2).jpeg
    kabupaten-kebumen|Kabupaten Kebumen|2026-05-02|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.27 (3).jpeg
    kabupaten-temanggung|Kabupaten Temanggung|2026-05-14|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.27.jpeg
    kabupaten-kendal|Kabupaten Kendal|2026-05-20|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.28 (1).jpeg
    kabupaten-demak|Kabupaten Demak|2026-05-31|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.28 (2).jpeg
    kabupaten-brebes|Kabupaten Brebes|2026-06-09|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.28.jpeg
    kabupaten-sidoarjo|Kabupaten Sidoarjo|2026-06-23|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.29 (1).jpeg
    kabupaten-gresik|Kabupaten Gresik|2026-06-29|source-image/WhatsApp Unknown 2026-11-26 at 13.33.54/WhatsApp Image 2026-10-18 at 09.56.29.jpeg
    kabupaten-lumajang|Kabupaten Lumajang|2026-07-11|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.50.51.jpeg
    kabupaten-jember|Kabupaten Jember|2026-07-18|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.51.02.jpeg
    kabupaten-banyuwangi|Kabupaten Banyuwangi|2026-08-01|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.51.18.jpeg
    kabupaten-tulungagung|Kabupaten Tulungagung|2026-08-08|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.51.29.jpeg
    kabupaten-nganjuk|Kabupaten Nganjuk|2026-08-21|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.51.51.jpeg
    kabupaten-ponorogo|Kabupaten Ponorogo|2026-08-28|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.52.05.jpeg
    kabupaten-tuban|Kabupaten Tuban|2026-09-09|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.52.40.jpeg
    kabupaten-lamongan|Kabupaten Lamongan|2026-09-16|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.52.51.jpeg
    kabupaten-badung|Kabupaten Badung|2026-09-29|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.53.07.jpeg
    kabupaten-gianyar|Kabupaten Gianyar|2026-10-05|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.53.16.jpeg
    kabupaten-tabanan|Kabupaten Tabanan|2026-10-16|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.53.31.jpeg
    kabupaten-karangasem|Kabupaten Karangasem|2026-10-25|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.53.41.jpeg
    kabupaten-buleleng|Kabupaten Buleleng|2026-11-07|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.53.50.jpeg
    kabupaten-jembrana|Kabupaten Jembrana|2026-11-14|source-image/WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.54.08.jpeg
  MANIFEST
  CITIES = MANIFEST.lines.map { |line| line.chomp.split("|", 4) }.freeze
  PREVIOUS_DATES = %w[
    2025-11-15 2025-11-19 2026-06-28 2026-11-26
    2025-12-19 2026-01-18 2026-02-17 2026-03-20 2026-04-20
    2026-05-24 2026-06-20 2026-07-26 2026-08-27 2026-09-22 2026-10-24
  ].freeze
  FORBIDDEN = /Sungguminasa|Malino|Makassar|Gowa|Sulawesi|Sulsel|在哪里|sakbis|\{\{|\{NAMA_KOTA\}|Pelanggan [0-9]/.freeze

  def test_all_photos_are_consumed_and_dates_are_unique_and_spread
    assert_equal 37, CITIES.size

    dates = CITIES.map { |_, _, tanggal, _| tanggal }
    assert_equal dates.uniq, dates, "tanggal nama file harus berbeda"
    assert dates.min >= "2025-11-15", "tanggal terlalu awal"
    assert dates.max <= "2026-11-26", "tanggal melewati hari ini"
    assert_operator dates.map { |date| date[0, 7] }.uniq.size, :>=, 10, "penyebaran bulan terlalu sempit"

    assert_empty dates & PREVIOUS_DATES, "tanggal baru tidak boleh menimpa tanggal artikel lama"
  end

  def test_articles_exist_and_pass_strict_validation
    CITIES.each do |slug, _, tanggal, _|
      path = article_path(slug, tanggal)
      assert File.file?(path), "artikel tidak ada: #{path}"

      result = CityPostValidator.validate_file(path, root: ROOT, strict: true)
      assert_empty result.errors, "#{slug}: #{result.errors.join('; ')}"
      assert_empty result.warnings, "#{slug}: #{result.warnings.join('; ')}"
    end
  end

  def test_frontmatter_city_and_timestamps
    CITIES.each do |slug, nama_kota, tanggal, _|
      path = article_path(slug, tanggal)
      text = File.read(path)
      data = PostTimestamps.frontmatter(path)

      assert_includes text, "nama_kota: #{nama_kota}", "#{slug}: nama kota salah"
      refute_match FORBIDDEN, text, "#{slug}: fakta lama atau placeholder tersisa"
      assert_equal "---", text.lines.first&.strip, "#{slug}: penanda frontmatter hilang"
      refute_equal "---", text.lines[1]&.strip, "#{slug}: penanda frontmatter ganda"
      assert_match PostTimestamps::PATTERN, data["date"], "#{slug}: format date salah"
      assert_match PostTimestamps::PATTERN, data["last_modified_at"], "#{slug}: format lastmod salah"
      assert_equal tanggal, PostTimestamps.parse(data["date"]).strftime("%Y-%m-%d"),
                   "#{slug}: tanggal tidak sesuai nama file"
      assert_operator PostTimestamps.parse(data["last_modified_at"]), :>, PostTimestamps.parse(data["date"])
    end
  end

  def test_provenance_covers_every_unique_source_photo
    entries = File.readlines(PROVENANCE).map { |line| JSON.parse(line) }
    used_sha = entries.map { |entry| entry["sha256"] }.uniq

    CITIES.each do |slug, _, tanggal, source|
      output = "/assets/images/posts/jual-kayu-dolken-#{slug}/jual-kayu-dolken-#{slug}-001.webp"
      entry = entries.find { |item| item["slug"] == slug && item["output"] == output }
      refute_nil entry, "provenance tidak ada untuk #{slug}"
      assert_equal tanggal, entry["tanggal"], "#{slug}: tanggal provenance salah"
      assert_equal source, entry["source"], "#{slug}: sumber provenance salah"
      source_path = SourceImage.path(ROOT, source.sub(%r{\Asource-image/}, ""))
      refute_nil source_path, "#{slug}: file sumber tidak ada"
      assert_equal Digest::SHA256.file(source_path).hexdigest, entry["sha256"]
      assert_equal entry["sha256"], entry["source_sha256"]
      assert_equal Digest::SHA256.file(File.join(ROOT, output.sub(%r{\A/}, ""))).hexdigest, entry["output_sha256"]
    end

    source_sha = Dir["source-image/**/*"].select { |file| File.file?(file) }
                                         .map { |file| Digest::SHA256.file(file).hexdigest }.uniq
    assert_equal source_sha.sort, used_sha.sort, "setiap foto unik source-image harus terpakai tepat sekali"
  end

  private

  def article_path(slug, tanggal)
    File.join(ROOT, "_post_with_city/#{tanggal}-jual-kayu-dolken-#{slug}.md")
  end
end
