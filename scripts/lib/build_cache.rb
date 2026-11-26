# frozen_string_literal: true

require "digest"
require "fileutils"

# Tanda tangan input build dipakai untuk membatalkan cache inkremental Jekyll
# ketika file yang memengaruhi semua halaman berubah.
module BuildCache
  SHARED_FILES = %w[Gemfile Gemfile.lock _config.yml _config_local.yml].freeze
  SHARED_DIRS = %w[_data _includes _layouts _plugins assets/css assets/js].freeze
  ARTICLE_DIRS = %w[_posts _post_with_city].freeze
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

    files_in(root, SHARED_DIRS, "**", "*").each do |relative, absolute|
      parts << "F\t#{relative}\t#{Digest::SHA256.file(absolute).hexdigest}\n"
    end

    files_in(root, ARTICLE_DIRS, "**", "*.md").each do |relative, _absolute|
      parts << "N\t#{relative}\n"
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

  def files_in(root, directories, *glob)
    directories.flat_map do |directory|
      base = File.join(root, directory)
      next [] unless File.directory?(base)

      Dir.glob(File.join(base, *glob), File::FNM_DOTMATCH).select { |path| File.file?(path) }
    end.map { |absolute| [absolute.delete_prefix("#{root}/"), absolute] }.sort_by(&:first)
  end
  private_class_method :files_in
end

puts BuildCache.prepare(root: Dir.pwd) if $PROGRAM_NAME == __FILE__ && ARGV[0] == "prepare"
