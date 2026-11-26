# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/lib/build_cache"

class BuildCacheTest < Minitest::Test
  def test_signature_stabil_bila_tidak_ada_perubahan
    Dir.mktmpdir do |root|
      make_root(root)
      first = BuildCache.signature(root)
      assert_equal first, BuildCache.signature(root)
    end
  end

  def test_signature_berubah_saat_file_data_diubah
    Dir.mktmpdir do |root|
      make_root(root)
      first = BuildCache.signature(root)
      File.write(File.join(root, "_data/area_pengiriman.yml"), "kota: baru\n")
      refute_equal first, BuildCache.signature(root)
    end
  end

  def test_signature_berubah_saat_nama_artikel_bertambah
    Dir.mktmpdir do |root|
      make_root(root)
      first = BuildCache.signature(root)
      FileUtils.touch(File.join(root, "_post_with_city/2026-11-27-jual-kayu-dolken-bogor.md"))
      refute_equal first, BuildCache.signature(root)
    end
  end

  def test_isi_artikel_tidak_mengubah_signature
    Dir.mktmpdir do |root|
      make_root(root)
      article = File.join(root, "_post_with_city/2026-11-26-jual-kayu-dolken-tangerang.md")
      first = BuildCache.signature(root)
      File.write(article, File.read(article) + "\n---\n")
      assert_equal first, BuildCache.signature(root)
    end
  end

  def test_prepare_menghapus_cache_basih_dan_menulis_signature
    Dir.mktmpdir do |root|
      make_root(root)
      cache = File.join(root, ".jekyll-cache")
      metadata = File.join(root, ".jekyll-metadata")
      FileUtils.mkdir_p(cache)
      File.write(File.join(cache, "stale"), "lama")
      File.write(metadata, "lama")

      assert_equal :reset, BuildCache.prepare(root: root)
      refute File.exist?(File.join(cache, "stale"))
      refute File.exist?(metadata)
      assert_equal BuildCache.signature(root),
                   File.read(File.join(cache, "build-inputs.sha256")).strip
      assert_equal :reuse, BuildCache.prepare(root: root)
    end
  end

  private

  def make_root(root)
    files = {
      "_config.yml" => "title: Contoh\n",
      "_data/area_pengiriman.yml" => "kota: [Tangerang]\n",
      "_layouts/default.html" => "{{ content }}\n",
      "assets/css/main.css" => "body { color: black; }\n",
      "_posts/2026-01-01-contoh.md" => "---\ntitle: Contoh\n---\n",
      "_post_with_city/2026-11-26-jual-kayu-dolken-tangerang.md" => "---\ntitle: Tangerang\n---\n"
    }
    files.each do |relative, content|
      path = File.join(root, relative)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
    end
  end
end
