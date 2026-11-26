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

  def test_isi_artikel_mengubah_signature
    Dir.mktmpdir do |root|
      make_root(root)
      article = File.join(root, "_post_with_city/2026-11-26-jual-kayu-dolken-tangerang.md")
      first = BuildCache.signature(root)
      File.write(article, File.read(article) + "\n---\n")
      refute_equal first, BuildCache.signature(root)
    end
  end

  def test_frontmatter_artikel_mengubah_signature
    Dir.mktmpdir do |root|
      make_root(root)
      article = File.join(root, "_post_with_city/2026-11-26-jual-kayu-dolken-tangerang.md")
      first = BuildCache.signature(root)
      File.write(article, "---\ntitle: Tangerang Baru\n---\n")
      refute_equal first, BuildCache.signature(root)
    end
  end

  def test_produk_baru_mengubah_signature
    Dir.mktmpdir do |root|
      make_root(root)
      first = BuildCache.signature(root)
      FileUtils.touch(File.join(root, "_products/kayu-dolken-11-12cm.md"))
      refute_equal first, BuildCache.signature(root)
    end
  end

  def test_halaman_root_mengubah_signature
    Dir.mktmpdir do |root|
      make_root(root)
      first = BuildCache.signature(root)
      File.write(File.join(root, "index.html"), "---\nlayout: default\n---\nbaru\n")
      refute_equal first, BuildCache.signature(root)
    end
  end

  def test_halaman_root_json_berfrontmatter_mengubah_signature
    Dir.mktmpdir do |root|
      make_root(root)
      page = File.join(root, "data.json")
      File.write(page, "---\nlayout: null\n---\n{}\n")
      first = BuildCache.signature(root)
      File.write(page, "---\nlayout: null\n---\n{\"baru\": true}\n")
      refute_equal first, BuildCache.signature(root)
    end
  end

  def test_config_rusak_tetap_menghash_direktori_produk
    Dir.mktmpdir do |root|
      make_root(root)
      File.write(File.join(root, "_config.yml"), "collections: [rusak\n")
      first = BuildCache.signature(root)
      FileUtils.touch(File.join(root, "_products/kayu-dolken-11-12cm.md"))
      refute_equal first, BuildCache.signature(root)
    end
  end

  def test_file_tersembunyi_di_shared_dir_mengubah_signature
    Dir.mktmpdir do |root|
      make_root(root)
      partial = File.join(root, "_includes/.partial.html")
      first = BuildCache.signature(root)
      File.write(partial, "baru\n")
      refute_equal first, BuildCache.signature(root)
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

  def test_prepare_reset_setelah_frontmatter_artikel_diubah
    Dir.mktmpdir do |root|
      make_root(root)
      assert_equal :reset, BuildCache.prepare(root: root)
      assert_equal :reuse, BuildCache.prepare(root: root)

      article = File.join(root, "_post_with_city/2026-11-26-jual-kayu-dolken-tangerang.md")
      File.write(article, "---\ntitle: Tangerang Baru\n---\n")
      assert_equal :reset, BuildCache.prepare(root: root)
    end
  end

  def test_prepare_reset_setelah_harga_produk_diubah
    Dir.mktmpdir do |root|
      make_root(root)
      assert_equal :reset, BuildCache.prepare(root: root)
      assert_equal :reuse, BuildCache.prepare(root: root)

      product = File.join(root, "_products/kayu-dolken-10-14cm.md")
      File.write(product, "---\ntitle: 10-14cm\nprice: 120000\n---\n")
      assert_equal :reset, BuildCache.prepare(root: root)
    end
  end

  private

  def make_root(root)
    files = {
      "_config.yml" => "title: Contoh\ncollections:\n  products:\n    output: true\n  post_with_city:\n    output: true\n",
      "_data/area_pengiriman.yml" => "kota: [Tangerang]\n",
      "_layouts/default.html" => "{{ content }}\n",
      "_includes/.partial.html" => "lama\n",
      "assets/css/main.css" => "body { color: black; }\n",
      "_posts/2026-01-01-contoh.md" => "---\ntitle: Contoh\n---\n",
      "_post_with_city/2026-11-26-jual-kayu-dolken-tangerang.md" => "---\ntitle: Tangerang\n---\n",
      "_products/kayu-dolken-10-14cm.md" => "---\ntitle: 10-14cm\nprice: 100000\n---\n",
      "_products/.keep" => "",
      "index.html" => "---\nlayout: default\n---\n{{ site.products.size }}\n"
    }
    files.each do |relative, content|
      path = File.join(root, relative)
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, content)
    end
  end
end
