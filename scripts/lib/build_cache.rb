# frozen_string_literal: true

require "digest"
require "fileutils"
require "yaml"

# Tanda tangan input build dipakai untuk membatalkan cache inkremental Jekyll.
# Halaman yang merender metadata atau keanggotaan koleksi (index, sitemap,
# daftar blog) tidak dibatalkan oleh regenerator Jekyll, sehingga seluruh
# dokumen koleksi dan halaman root ber-frontmatter ikut di-hash.
module BuildCache
  SHARED_FILES = %w[Gemfile Gemfile.lock _config.yml _config_local.yml].freeze
  SHARED_DIRS = %w[_data _includes _layouts _plugins assets/css assets/js].freeze
  ROOT_PAGE_EXTENSIONS = %w[.html .xml .md].freeze
  STAMP = "build-inputs.sha256"

  module_function

  def signature(root)
    root = File.expand_path(root)
    parts = +""

    SHARED_FILES.each do |relative|
      absolute = File.join(root, relative)
      next unless File.file?(absolute)

      parts << "F\t#{relative}\t#{Digest::SHA256.file(absolute).hexdigest}\n"
    end

    files_in(root, SHARED_DIRS).each do |relative, absolute|
      parts << "F\t#{relative}\t#{Digest::SHA256.file(absolute).hexdigest}\n"
    end

    files_in(root, collection_dirs(root)).each do |relative, absolute|
      parts << "C\t#{relative}\t#{Digest::SHA256.file(absolute).hexdigest}\n"
    end

    root_pages(root).each do |relative, absolute|
      parts << "P\t#{relative}\t#{Digest::SHA256.file(absolute).hexdigest}\n"
    end

    Digest::SHA256.hexdigest(parts)
  end

  def prepare(root:, cache_dir: ".jekyll-cache", metadata_file: ".jekyll-metadata")
    root = File.expand_path(root)
    stamp = File.join(root, cache_dir, STAMP)
    current = signature(root)
    return :reuse if File.file?(stamp) && File.read(stamp).strip == current

    FileUtils.rm_rf(File.join(root, cache_dir))
    FileUtils.rm_f(File.join(root, metadata_file))
    FileUtils.mkdir_p(File.dirname(stamp))
    File.write(stamp, "#{current}\n")
    :reset
  end

  def collection_dirs(root)
    dirs = ["_posts"]
    config = File.join(root, "_config.yml")
    if File.file?(config)
      begin
        data = YAML.safe_load(File.read(config), aliases: true)
        collections = data["collections"] if data.is_a?(Hash)
        dirs.concat(collections.keys.map { |name| "_#{name}" }) if collections.is_a?(Hash)
      rescue Psych::Exception
        # Konfigurasi tidak terbaca; _posts tetap diperiksa.
      end
    end
    dirs.uniq
  end
  private_class_method :collection_dirs

  def root_pages(root)
    Dir.children(root).select do |name|
      absolute = File.join(root, name)
      ROOT_PAGE_EXTENSIONS.include?(File.extname(name)) &&
        File.file?(absolute) &&
        File.foreach(absolute).first.to_s.strip == "---"
    end.sort.map { |name| [name, File.join(root, name)] }
  end
  private_class_method :root_pages

  def files_in(root, directories)
    directories.flat_map do |directory|
      base = File.join(root, directory)
      next [] unless File.directory?(base)

      Dir.glob(File.join(base, "**", "*")).select { |path| File.file?(path) }
    end.map { |absolute| [absolute.delete_prefix("#{root}/"), absolute] }.sort_by(&:first)
  end
  private_class_method :files_in
end

puts BuildCache.prepare(root: Dir.pwd) if $PROGRAM_NAME == __FILE__ && ARGV[0] == "prepare"
