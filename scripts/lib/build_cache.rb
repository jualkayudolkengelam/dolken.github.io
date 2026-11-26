# frozen_string_literal: true

require "digest"
require "fileutils"

# Tanda tangan input build dipakai untuk membatalkan cache inkremental Jekyll.
# Halaman yang merender metadata atau keanggotaan koleksi (index, sitemap,
# daftar blog) tidak dibatalkan oleh regenerator Jekyll, sehingga seluruh
# dokumen koleksi dan halaman root ber-frontmatter ikut di-hash.
module BuildCache
  SHARED_FILES = %w[Gemfile Gemfile.lock _config.yml _config_local.yml].freeze
  SHARED_DIRS = %w[_data _includes _layouts _plugins assets/css assets/js].freeze
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

  # Semua direktori `_...` adalah kandidat koleksi Jekyll. Memakai daftar
  # direktori, bukan konfigurasi YAML, menghindari perbedaan parser antara
  # script ini dan Jekyll serta mencakup koleksi dari `_config_local.yml`.
  def collection_dirs(root)
    dirs = Dir.children(root).select do |name|
      name.start_with?("_") && name != "_site" && File.directory?(File.join(root, name))
    end
    dirs << "_posts" unless dirs.include?("_posts")
    dirs.sort.uniq
  end
  private_class_method :collection_dirs

  # Frontmatter boleh memakai ekstensi apa pun; yang menentukan adalah baris
  # pertama `---`. File tersembunyi (dotfile) tidak dianggap halaman.
  def root_pages(root)
    Dir.children(root).select do |name|
      absolute = File.join(root, name)
      !name.start_with?(".") && File.file?(absolute) && File.foreach(absolute).first.to_s.strip == "---"
    end.sort.map { |name| [name, File.join(root, name)] }
  end
  private_class_method :root_pages

  def files_in(root, directories)
    directories.flat_map do |directory|
      base = File.join(root, directory)
      next [] unless File.directory?(base)

      Dir.glob(File.join(base, "**", "*"), File::FNM_DOTMATCH).select { |path| File.file?(path) }
    end.map { |absolute| [absolute.delete_prefix("#{root}/"), absolute] }.sort_by(&:first)
  end
  private_class_method :files_in
end

puts BuildCache.prepare(root: Dir.pwd) if $PROGRAM_NAME == __FILE__ && ARGV[0] == "prepare"
