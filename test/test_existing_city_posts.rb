# frozen_string_literal: true

require "minitest/autorun"
require "yaml"
require_relative "../scripts/lib/city_post_schema"
require_relative "../scripts/validate-city-post"

class ExistingCityPostsTest < Minitest::Test
  POSTS = Dir["_post_with_city/*.md"].sort.freeze

  def frontmatter(path)
    text = File.read(path)
    YAML.safe_load(text[/\A---\n(.*?)\n---\n/m, 1],
                   permitted_classes: [Date, Time], aliases: true) || {}
  end

  def test_all_existing_posts_have_canonical_fields
    refute_empty POSTS, "tidak ada artikel kota untuk divalidasi"

    POSTS.each do |path|
      missing = CityPostSchema.missing_fields(frontmatter(path))
      assert_empty missing, "#{path} kehilangan field: #{missing.join(', ')}"
    end
  end

  def test_validator_reports_no_warnings
    POSTS.each do |path|
      result = CityPostValidator.validate_file(File.expand_path(path), root: Dir.pwd)
      assert_empty result.errors, "#{path} memiliki error: #{result.errors.join(', ')}"
      assert_empty result.warnings, "#{path} memiliki warning: #{result.warnings.join(', ')}"
    end
  end
end
