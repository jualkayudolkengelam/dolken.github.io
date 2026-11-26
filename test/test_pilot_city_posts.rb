# frozen_string_literal: true

require "digest"
require "json"
require "minitest/autorun"
require_relative "../scripts/validate-city-post"

class PilotCityPostsTest < Minitest::Test
  ROOT = File.expand_path("..", __dir__)
  SLUGS = %w[tangerang surabaya denpasar].freeze
  PROVENANCE = File.join(ROOT, "scripts/data/image-provenance.jsonl")

  def test_generated_pilot_articles_exist
    SLUGS.each do |slug|
      assert File.file?(article_path(slug)), "artikel tidak ada: #{article_path(slug)}"
    end
  end

  def test_generated_articles_have_no_template_placeholders
    SLUGS.each do |slug|
      body = File.read(article_path(slug))[/\A---\n.*?\n---\n(.*)\z/m, 1]
      refute_match(/\{NAMA_KOTA\}|\{\{[^}]+\}\}/, body, "#{slug}: placeholder tersisa di body artikel")
    end
  end

  def test_generated_pilot_articles_pass_strict_validation
    SLUGS.each do |slug|
      assert File.file?(article_path(slug)), "artikel tidak ada: #{article_path(slug)}"
      result = CityPostValidator.validate_file(article_path(slug), root: ROOT, strict: true)
      assert_empty result.errors, "#{slug}: #{result.errors.join('; ')}"
      assert_empty result.warnings, "#{slug}: #{result.warnings.join('; ')}"
    end
  end

  def test_provenance_matches_generated_images
    entries = File.file?(PROVENANCE) ? File.readlines(PROVENANCE).map { |line| JSON.parse(line) } : []

    SLUGS.each do |slug|
      output = "/assets/images/posts/jual-kayu-dolken-#{slug}/jual-kayu-dolken-#{slug}-001.webp"
      entry = entries.find { |item| item["slug"] == slug && item["output"] == output }
      refute_nil entry, "provenance tidak ada untuk #{slug}"
      assert entry["source"].to_s.start_with?("source-image/"), "source bukan dari source-image/: #{slug}"
      assert File.file?(File.join(ROOT, entry["source"])), "file sumber provenance tidak ada: #{slug}"
      assert_equal Digest::SHA256.file(File.join(ROOT, output.sub(%r{\A/}, ""))).hexdigest,
                   entry["output_sha256"], "sha256 output tidak cocok: #{slug}"
    end
  end

  private

  def article_path(slug)
    File.join(ROOT, "_post_with_city/2026-11-26-jual-kayu-dolken-#{slug}.md")
  end
end
