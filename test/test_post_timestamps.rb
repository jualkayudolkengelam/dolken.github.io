# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "minitest/mock"
require "tmpdir"
require_relative "../scripts/generate-city-post"
require_relative "../scripts/lib/post_timestamps"

class PostTimestampsTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  FILENAME_DATE = "2026-11-26"

  def test_all_city_articles_have_unique_utc_timestamps
    result = PostTimestamps.validate(root: ROOT)
    assert_empty result.errors, result.errors.join("; ")
  end

  def test_validator_rejects_duplicate_date
    Dir.mktmpdir do |dir|
      write_article(dir, "a", "date: '2026-11-26 01:00:00 +0000'", "last_modified_at: '2026-11-26 02:00:00 +0000'")
      write_article(dir, "b", "date: '2026-11-26 01:00:00 +0000'", "last_modified_at: '2026-11-26 02:00:01 +0000'")

      errors = PostTimestamps.validate(root: dir).errors
      assert errors.any? { |error| error.include?("duplikat") && error.include?("date") }, errors.inspect
    end
  end

  def test_validator_rejects_non_utc_or_secondless_format
    ["'2026-11-26 01:00 +0000'", "'2026-11-26 08:00:00 +0700'", "2026-11-26"].each do |bad_date|
      Dir.mktmpdir do |dir|
        write_article(dir, "a", "date: #{bad_date}", "last_modified_at: '2026-11-26 02:00:00 +0000'")
        errors = PostTimestamps.validate(root: dir).errors
        assert errors.any? { |error| error.include?("format") }, "#{bad_date}: #{errors.inspect}"
      end
    end
  end

  def test_validator_rejects_modified_before_date
    Dir.mktmpdir do |dir|
      write_article(dir, "a", "date: '2026-11-26 01:00:00 +0000'", "last_modified_at: '2026-11-26 00:30:00 +0000'")

      errors = PostTimestamps.validate(root: dir).errors
      assert errors.any? { |error| error.include?("last_modified_at") && error.include?("lebih awal") }, errors.inspect
    end
  end

  def test_validator_rejects_date_that_does_not_match_filename
    Dir.mktmpdir do |dir|
      write_article(dir, "a", "date: '2026-11-25 01:00:00 +0000'", "last_modified_at: '2026-11-26 02:00:00 +0000'")

      errors = PostTimestamps.validate(root: dir).errors
      assert errors.any? { |error| error.include?("nama file") }, errors.inspect
    end
  end

  def test_format_parse_and_next_unique
    time = Time.utc(2026, 11, 26, 3, 17, 42)
    formatted = PostTimestamps.format(time)
    assert_equal "2026-11-26 03:17:42 +0000", formatted
    assert_equal time, PostTimestamps.parse(formatted)
    assert_nil PostTimestamps.parse("2026-11-26 03:17 +0000")
    assert_nil PostTimestamps.parse("2026-11-26 10:17:42 +0700")

    assert_equal "2026-11-26 03:17:43 +0000", PostTimestamps.next_unique(time, [formatted])
  end

  def test_natural_times_are_within_window_and_deterministic
    publish, modified = PostTimestamps.natural_times(slug: "bogor", tanggal: FILENAME_DATE)

    assert_equal FILENAME_DATE, publish.strftime("%Y-%m-%d")
    assert_includes 1..5, publish.hour
    assert_operator publish, :>=, Time.utc(2026, 11, 26, 1, 0, 0)
    assert_operator publish, :<=, Time.utc(2026, 11, 26, 5, 30, 0)
    assert_operator modified, :>, publish
    assert_equal [publish, modified], PostTimestamps.natural_times(slug: "bogor", tanggal: FILENAME_DATE)
    refute_equal publish, PostTimestamps.natural_times(slug: "depok", tanggal: FILENAME_DATE).first
  end

  def test_allocate_avoids_values_already_used
    Dir.mktmpdir do |dir|
      write_article(dir, "existing", "date: '2026-11-26 01:00:00 +0000'", "last_modified_at: '2026-11-26 02:00:00 +0000'")
      taken = [Time.utc(2026, 11, 26, 1, 0, 0), Time.utc(2026, 11, 26, 2, 0, 0)]

      date, modified = PostTimestamps.stub(:natural_times, taken) do
        PostTimestamps.allocate(root: dir, slug: "baru", tanggal: FILENAME_DATE)
      end

      assert_equal "2026-11-26 01:00:01 +0000", date
      assert_equal "2026-11-26 02:00:01 +0000", modified
    end
  end

  def test_generator_writes_valid_unique_timestamps
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "source-image"))
      File.write(File.join(dir, "source-image/sample.jpeg"), "gambar contoh")
      city = {
        "slug" => "kota-baru",
        "nama_kota" => "Kota Baru",
        "tanggal" => FILENAME_DATE,
        "foto_source" => "sample.jpeg"
      }

      CityPostGenerator.stub(:convert_to_webp, ->(src, dest) { FileUtils.cp(src, dest) }) do
        CityPostGenerator.generate(city, root: dir)
      end

      path = File.join(dir, "_post_with_city", "#{FILENAME_DATE}-jual-kayu-dolken-kota-baru.md")
      data = PostTimestamps.frontmatter(path)
      assert_match PostTimestamps::PATTERN, data["date"]
      assert_match PostTimestamps::PATTERN, data["last_modified_at"]
      assert_equal FILENAME_DATE, PostTimestamps.parse(data["date"]).strftime("%Y-%m-%d")
      assert_operator PostTimestamps.parse(data["last_modified_at"]), :>, PostTimestamps.parse(data["date"])
    end
  end

  private

  def write_article(dir, slug, date_line, modified_line)
    path = File.join(dir, "_post_with_city", "#{FILENAME_DATE}-jual-kayu-dolken-#{slug}.md")
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, "---\nlayout: post\n#{date_line}\n#{modified_line}\n---\nIsi.\n")
    path
  end
end
