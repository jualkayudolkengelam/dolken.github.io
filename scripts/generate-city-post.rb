# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"
require "optparse"
require "yaml"
require_relative "lib/city_post_schema"
require_relative "lib/city_profile"

module CityPostGenerator
  class Error < StandardError; end
  class SourceImageMissingError < Error; end
  class OutputExistsError < Error; end
  class DuplicateImageError < Error; end

  module_function

  def image_sha256(path)
    Digest::SHA256.file(path).hexdigest
  end

  def convert_to_webp(src, dest)
    ok = system("ffmpeg", "-hide_banner", "-loglevel", "error",
                "-i", src, "-c:v", "libwebp", "-quality", "85", dest,
                out: File::NULL, err: File::NULL)
    raise Error, "ffmpeg gagal mengonversi #{src}" unless ok
  end

  def append_provenance(root:, entry:)
    path = File.join(root, "scripts/data/image-provenance.jsonl")
    FileUtils.mkdir_p(File.dirname(path))
    File.open(path, "a") { |file| file.puts(JSON.generate(entry)) }
  end

  def generate(city, root:, defaults: CityProfile.load_defaults, dry_run: false)
    CityProfile.validate_city!(city)
    slug = city.fetch("slug")
    source = source_image_path(root, city.fetch("foto_source"))
    sha = image_sha256(source)

    article_rel = "_post_with_city/#{city.fetch('tanggal')}-jual-kayu-dolken-#{slug}.md"
    raise OutputExistsError, "artikel sudah ada: #{article_rel}" if File.exist?(File.join(root, article_rel))

    image_path = "/assets/images/posts/jual-kayu-dolken-#{slug}/jual-kayu-dolken-#{slug}-001.webp"
    webp_path = File.join(root, image_path.sub(%r{\A/}, ""))
    jpeg_copy = File.join(File.dirname(webp_path), "#{File.basename(image_path, '.webp')}.jpeg")
    if File.exist?(webp_path) || File.exist?(jpeg_copy)
      raise OutputExistsError, "gambar sudah ada: #{image_path}"
    end

    merged = CityProfile.merge(defaults, city)
    images = Array(merged["images"])
    images = [image_path] if images.empty?
    ensure_unique_hashes(images, root: root, fallback_path: image_path, fallback_sha: sha)

    return article_rel if dry_run

    FileUtils.mkdir_p(File.dirname(webp_path))
    begin
      FileUtils.cp(source, jpeg_copy)
      convert_to_webp(jpeg_copy, webp_path)
    ensure
      FileUtils.rm_f(jpeg_copy)
    end
    output_sha = image_sha256(webp_path)

    merged["image"] = image_path
    merged["images"] = [image_path]
    body_path = File.expand_path("data/city-post-body.md", __dir__)
    body = CityProfile.substitute(File.read(body_path), city)
    article_path = File.join(root, article_rel)
    FileUtils.mkdir_p(File.dirname(article_path))
    File.write(article_path, "---\n#{YAML.dump(merged)}---\n#{body}")

    append_provenance(
      root: root,
      entry: {
        "sha256" => sha,
        "source_sha256" => sha,
        "output_sha256" => output_sha,
        "source" => File.join("source-image", city.fetch("foto_source")),
        "output" => image_path,
        "slug" => slug,
        "tanggal" => city.fetch("tanggal")
      }
    )
    article_rel
  end

  def source_image_path(root, foto_source)
    source_root = File.expand_path(File.join(root, "source-image"))
    candidate = File.expand_path(File.join(source_root, foto_source.to_s))
    return candidate if candidate.start_with?(source_root + File::SEPARATOR) && File.file?(candidate)

    raise SourceImageMissingError, "foto source-image tidak ditemukan: #{foto_source}"
  end

  def ensure_unique_hashes(images, root:, fallback_path:, fallback_sha:)
    hashes = images.map do |path|
      next fallback_sha if path == fallback_path

      full = File.join(root, path.to_s.sub(%r{\A/}, ""))
      raise SourceImageMissingError, "gambar artikel tidak ditemukan: #{path}" unless File.file?(full)

      image_sha256(full)
    end
    raise DuplicateImageError, "hash gambar duplikat dalam satu artikel" unless hashes.uniq.size == hashes.size

    true
  end
end

if $PROGRAM_NAME == __FILE__
  options = { profile: "scripts/data/city-profiles.yml", slug: nil, dry_run: false }
  OptionParser.new do |parser|
    parser.on("--profile PATH") { |value| options[:profile] = value }
    parser.on("--slug SLUG") { |value| options[:slug] = value }
    parser.on("--dry-run") { options[:dry_run] = true }
  end.parse!

  begin
    profile = CityProfile.load(options[:profile])
    defaults = profile["defaults"].to_h.empty? ? CityProfile.load_defaults : profile["defaults"]
    cities = profile["cities"] || []
    cities = cities.select { |city| city["slug"] == options[:slug] } if options[:slug]
    cities.each do |city|
      puts CityPostGenerator.generate(city, root: Dir.pwd, defaults: defaults, dry_run: options[:dry_run])
    end
  rescue CityPostGenerator::Error, ArgumentError => e
    warn "ERROR: #{e.message}"
    exit 1
  end
end
