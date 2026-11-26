# frozen_string_literal: true

require "minitest/autorun"
require "tmpdir"
require "fileutils"
require "yaml"
require "open3"
require_relative "../scripts/lib/city_post_schema"
require_relative "../scripts/lib/city_profile"
require_relative "../scripts/generate-city-post"
require_relative "../scripts/validate-city-post"

class ValidateCityPostTest < Minitest::Test
  IMAGE_PATH = "/assets/images/posts/jual-kayu-dolken-bogor/jual-kayu-dolken-bogor-001.webp"

  def setup
    @root = Dir.mktmpdir("city-validator-test")
    FileUtils.mkdir_p(File.join(@root, "source-image"))
    @photo = File.join(@root, "source-image", "sample.jpeg")
    ok = system("ffmpeg", "-hide_banner", "-loglevel", "error", "-f", "lavfi",
                "-i", "color=c=red:s=64x64", "-frames:v", "1", @photo,
                out: File::NULL, err: File::NULL)
    flunk "ffmpeg fixture creation failed" unless ok

    city = {
      "slug" => "bogor", "nama_kota" => "Bogor",
      "tanggal" => "2026-12-01", "foto_source" => "sample.jpeg"
    }
    @article_rel = CityPostGenerator.generate(city, root: @root, defaults: CityProfile.load_defaults)
    @valid_path = File.join(@root, @article_rel)
  end

  def teardown
    FileUtils.remove_entry(@root)
  end

  def test_valid_article_has_no_errors_or_warnings
    result = CityPostValidator.validate_file(@valid_path, root: @root)
    assert_empty result.errors
    assert_empty result.warnings
    assert result.success?
  end

  def test_legacy_article_missing_fields_is_warning_by_default
    legacy = write_variant("2025-01-01-jual-kayu-dolken-legacy.md") do |fm|
      %w[like_count share_count comment_count rating review_count show_products author_url].each do |key|
        fm.delete(key)
      end
      fm
    end
    result = CityPostValidator.validate_file(legacy, root: @root)
    assert_empty result.errors
    assert result.warnings.any? { |warning| warning.include?("like_count") }
  end

  def test_wrong_filename_is_warning
    bad = write_variant("artikel.md") { |fm| fm }
    result = CityPostValidator.validate_file(bad, root: @root)
    assert_empty result.errors
    assert result.warnings.any? { |warning| warning.include?("nama file") }
  end

  def test_placeholder_is_error
    bad = write_variant("2026-12-01-jual-kayu-dolken-placeholder.md") do |fm|
      fm["title"] = "Jual {{nama_kota}}"
      fm
    end
    refute_empty CityPostValidator.validate_file(bad, root: @root).errors
  end

  def test_missing_image_file_is_error
    bad = write_variant("2026-12-01-jual-kayu-dolken-missing.md") do |fm|
      fm["image"] = "/assets/images/posts/tidak-ada.webp"
      fm["images"] = ["/assets/images/posts/tidak-ada.webp"]
      fm
    end
    refute_empty CityPostValidator.validate_file(bad, root: @root).errors
  end

  def test_duplicate_image_hashes_are_error
    dir = File.join(@root, "assets/images/posts/dup")
    FileUtils.mkdir_p(dir)
    File.binwrite(File.join(dir, "a.webp"), "sama")
    File.binwrite(File.join(dir, "b.webp"), "sama")
    bad = write_variant("2026-12-01-jual-kayu-dolken-dup.md") do |fm|
      fm["image"] = "/assets/images/posts/dup/a.webp"
      fm["images"] = ["/assets/images/posts/dup/a.webp", "/assets/images/posts/dup/b.webp"]
      fm
    end
    refute_empty CityPostValidator.validate_file(bad, root: @root).errors
  end

  def test_strict_mode_rejects_legacy_missing_fields
    legacy = write_variant("2025-01-01-jual-kayu-dolken-legacy.md") do |fm|
      fm.delete("like_count")
      fm
    end
    refute_empty CityPostValidator.validate_file(legacy, root: @root, strict: true).errors
  end

  def test_strict_mode_requires_matching_provenance
    FileUtils.rm(File.join(@root, "scripts/data/image-provenance.jsonl"))
    refute_empty CityPostValidator.validate_file(@valid_path, root: @root, strict: true).errors
  end

  def test_strict_mode_requires_exactly_one_image
    other = "/assets/images/posts/other.webp"
    File.binwrite(File.join(@root, other.sub(%r{\A/}, "")), "berbeda")
    bad = write_variant("2026-12-01-jual-kayu-dolken-two.md") do |fm|
      fm["images"] = [IMAGE_PATH, other]
      fm
    end
    refute_empty CityPostValidator.validate_file(bad, root: @root, strict: true).errors
  end

  def test_cli_works_in_a_fresh_process
    script = File.expand_path("../scripts/validate-city-post.rb", __dir__)
    stdout, stderr, status = Open3.capture3("ruby", script, @valid_path, chdir: @root)
    assert status.success?, "CLI gagal: #{stderr}"
    assert_includes stdout, "OK:"
  end

  private

  def write_variant(name)
    text = File.read(@valid_path)
    frontmatter = YAML.safe_load(text[/\A---\n(.*?)\n---\n/m, 1], permitted_classes: [Date, Time])
    updated = yield(frontmatter)
    body = text.sub(/\A---\n.*?\n---\n/m, "")
    path = File.join(@root, "_post_with_city", name)
    File.write(path, "---\n#{YAML.dump(updated)}---\n#{body}")
    path
  end
end
