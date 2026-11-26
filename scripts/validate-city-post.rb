# frozen_string_literal: true

require "date"
require "digest"
require "json"
require "yaml"
require_relative "lib/city_post_schema"

module CityPostValidator
  Result = Struct.new(:errors, :warnings, keyword_init: true) do
    def success?
      errors.empty?
    end
  end

  FILENAME_PATTERN = /\A\d{4}-\d{2}-\d{2}-jual-kayu-dolken-.*\.md\z/.freeze
  PROVENANCE_PATH = "scripts/data/image-provenance.jsonl"

  module_function

  def validate_file(path, root: Dir.pwd, strict: false)
    errors = []
    warnings = []
    text = File.read(path)
    frontmatter = YAML.safe_load(text[/\A---\n(.*?)\n---\n/m, 1],
                                 permitted_classes: [Date, Time], aliases: true) || {}

    check_fields(frontmatter, errors, warnings, strict)
    CityPostSchema.placeholders(frontmatter).each do |field|
      errors << "placeholder ditemukan di field: #{field}"
    end
    hashes = check_images(frontmatter, root, errors)
    check_filename(path, warnings)
    check_strict(frontmatter, root, errors, hashes) if strict

    Result.new(errors: errors, warnings: warnings)
  end

  def check_fields(frontmatter, errors, warnings, strict)
    CityPostSchema.missing_fields(frontmatter).each do |field|
      message = "field wajib hilang: #{field}"
      strict ? errors << message : warnings << message
    end
  end

  def check_images(frontmatter, root, errors)
    images = Array(frontmatter["images"])
    primary = frontmatter["image"]
    errors << "field image harus sama dengan images.first" if primary && !images.empty? && primary != images.first

    paths = ([primary] + images).compact.uniq
    paths.each do |image_path|
      unless image_path.is_a?(String) && image_path.end_with?(".webp")
        errors << "path gambar bukan WebP: #{image_path}"
      end
    end

    hashes = images.filter_map do |image_path|
      full = File.join(root, image_path.to_s.sub(%r{\A/}, ""))
      unless File.file?(full)
        errors << "file gambar tidak ditemukan: #{image_path}"
        next nil
      end
      Digest::SHA256.file(full).hexdigest
    end
    errors << "hash gambar duplikat dalam satu artikel" unless hashes.uniq.size == hashes.size

    hashes
  end

  def check_filename(path, warnings)
    return if FILENAME_PATTERN.match?(File.basename(path))

    warnings << "Format nama file harus YYYY-MM-DD-jual-kayu-dolken-{kota}.md"
  end

  def check_strict(frontmatter, root, errors, hashes)
    images = Array(frontmatter["images"])
    alts = Array(frontmatter["images_alt"])
    errors << "artikel baru harus memiliki tepat satu gambar" unless images.size == 1
    errors << "artikel baru harus memiliki tepat satu keterangan gambar" unless alts.size == 1

    provenance_path = File.join(root, PROVENANCE_PATH)
    unless File.file?(provenance_path)
      errors << "catatan provenance gambar tidak ditemukan"
      return
    end

    entries = File.readlines(provenance_path).filter_map { |line| JSON.parse(line) rescue nil }
    match = entries.find do |entry|
      entry["output"] == images.first &&
        (entry["output_sha256"] || entry["sha256"]) == hashes.first &&
        entry["source"].to_s.start_with?("source-image/")
    end
    errors << "gambar tidak memiliki provenance source-image yang cocok" unless match
  end
end

if $PROGRAM_NAME == __FILE__
  strict = false
  files = []
  ARGV.each do |arg|
    case arg
    when "--new" then strict = true
    else files << arg
    end
  end

  if files.empty?
    warn "Usage: validate-post.sh [--new] <file.md>"
    exit 1
  end

  failures = 0
  files.each do |file|
    result = CityPostValidator.validate_file(File.expand_path(file), root: Dir.pwd, strict: strict)
    result.warnings.each { |warning| warn "WARNING: #{warning}" }
    result.errors.each { |error| warn "ERROR: #{error}" }
    puts "OK: #{file}" if result.success?
    failures += 1 unless result.success?
  end
  exit(failures.zero? ? 0 : 1)
end
