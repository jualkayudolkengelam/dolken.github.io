# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "digest"
require "json"
require "yaml"
require_relative "../scripts/lib/city_post_schema"
require_relative "../scripts/lib/city_profile"
require_relative "../scripts/generate-city-post"

class GenerateCityPostTest < Minitest::Test
  IMAGE_PATH = "/assets/images/posts/jual-kayu-dolken-bogor/jual-kayu-dolken-bogor-001.webp"

  def setup
    @root = Dir.mktmpdir("city-post-test")
    FileUtils.mkdir_p(File.join(@root, "source-image"))
    @photo = File.join(@root, "source-image", "sample.jpeg")
    ok = system("ffmpeg", "-hide_banner", "-loglevel", "error", "-f", "lavfi",
                "-i", "color=c=red:s=64x64", "-frames:v", "1", @photo,
                out: File::NULL, err: File::NULL)
    flunk "ffmpeg fixture creation failed" unless ok

    @defaults = CityProfile.load_defaults
    @city = {
      "slug" => "bogor", "nama_kota" => "Bogor",
      "tanggal" => "2026-12-01", "foto_source" => "sample.jpeg"
    }
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def test_generate_writes_complete_article_and_webp
    path = CityPostGenerator.generate(@city, root: @root, defaults: @defaults)
    assert_equal "_post_with_city/2026-12-01-jual-kayu-dolken-bogor.md", path

    full_path = File.join(@root, path)
    assert File.file?(full_path)

    text = File.read(full_path)
    frontmatter = YAML.safe_load(text[/\A---\n(.*?)\n---\n/m, 1])
    assert_equal CityPostSchema::REQUIRED_FIELDS.sort, frontmatter.keys.sort
    assert_includes text, "{% include reusable/post-with-city/block--hero-jual-kayu-dolken.html %}"
    assert_includes text, 'nama_kota="Bogor"'
    refute_includes text, "{{"

    assert_equal IMAGE_PATH, frontmatter["image"]
    assert_equal IMAGE_PATH, frontmatter["images"][0]
    webp = File.join(@root, IMAGE_PATH.sub(%r{\A/}, ""))
    assert File.file?(webp)
    assert_empty Dir.glob(File.join(File.dirname(webp), "*.jpeg"))

    entries = File.readlines(File.join(@root, "scripts/data/image-provenance.jsonl")).map do |line|
      JSON.parse(line)
    end
    assert_equal 1, entries.size
    assert_equal Digest::SHA256.file(@photo).hexdigest, entries[0]["sha256"]
    assert_equal "source-image/sample.jpeg", entries[0]["source"]
    assert_equal "bogor", entries[0]["slug"]
  end

  def test_dry_run_does_not_write_article_or_image
    solo = @city.merge("slug" => "solo", "nama_kota" => "Solo")
    CityPostGenerator.generate(solo, root: @root, defaults: @defaults, dry_run: true)
    refute File.exist?(File.join(@root, "_post_with_city/2026-12-01-jual-kayu-dolken-solo.md"))
    refute File.exist?(File.join(@root, "assets/images/posts/jual-kayu-dolken-solo"))
  end

  def test_duplicate_image_hashes_are_rejected
    dir = File.join(@root, "assets/images/posts/dup")
    FileUtils.mkdir_p(dir)
    File.binwrite(File.join(dir, "a.webp"), "identical bytes")
    File.binwrite(File.join(dir, "b.webp"), "identical bytes")
    city = @city.merge(
      "overrides" => {
        "images" => [
          "/assets/images/posts/dup/a.webp",
          "/assets/images/posts/dup/b.webp"
        ]
      }
    )

    assert_raises(CityPostGenerator::DuplicateImageError) do
      CityPostGenerator.generate(city, root: @root, defaults: @defaults)
    end
    refute File.exist?(File.join(@root, "_post_with_city/2026-12-01-jual-kayu-dolken-bogor.md"))
  end

  def test_missing_or_outside_source_photo_is_rejected
    missing = @city.merge("foto_source" => "missing.jpeg")
    assert_raises(CityPostGenerator::SourceImageMissingError) do
      CityPostGenerator.generate(missing, root: @root, defaults: @defaults)
    end

    File.binwrite(File.join(@root, "luar.jpeg"), "outside")
    outside = @city.merge("foto_source" => "../luar.jpeg")
    assert_raises(CityPostGenerator::SourceImageMissingError) do
      CityPostGenerator.generate(outside, root: @root, defaults: @defaults)
    end
    refute File.exist?(File.join(@root, "assets/images/posts/jual-kayu-dolken-bogor"))
  end

  def test_existing_article_is_not_overwritten
    CityPostGenerator.generate(@city, root: @root, defaults: @defaults)
    article = File.join(@root, "_post_with_city/2026-12-01-jual-kayu-dolken-bogor.md")
    before = File.read(article)

    assert_raises(CityPostGenerator::OutputExistsError) do
      CityPostGenerator.generate(@city, root: @root, defaults: @defaults)
    end
    assert_equal before, File.read(article)
  end
end
