# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "tmpdir"
require_relative "../scripts/generate-city-post"
require_relative "../scripts/lib/source_image"

class SourceImageArchiveTest < Minitest::Test
  def test_resolver_memilih_foto_baru_di_root_bukan_arsip
    Dir.mktmpdir do |root|
      write_photo(root, "sama.jpeg", "baru")
      write_photo(root, "sama.jpeg", "lama", archived: true)

      path = SourceImage.path(root, "sama.jpeg")
      refute_nil path
      assert_equal File.join(root, "source-image/sama.jpeg"), path
      assert_equal "baru", File.read(path)
    end
  end

  def test_resolver_jatuh_ke_arsip_untuk_foto_yang_sudah_terpakai
    Dir.mktmpdir do |root|
      write_photo(root, "lama.jpeg", "arsip", archived: true)

      path = SourceImage.path(root, "lama.jpeg")
      refute_nil path
      assert_equal File.join(root, "source-image/sudah-terpakai/lama.jpeg"), path
    end
  end

  def test_resolver_menolak_path_keluar_direktori_source_image
    Dir.mktmpdir do |root|
      File.write(File.join(root, "luar.jpeg"), "luar")

      assert_nil SourceImage.path(root, "../luar.jpeg")
      assert_nil SourceImage.path(root, "/etc/passwd")
      assert_nil SourceImage.path(root, "sudah-terpakai/../../luar.jpeg")
    end
  end

  def test_generator_menolak_foto_yang_sudah_diarsipkan
    Dir.mktmpdir do |root|
      write_photo(root, "arsip.jpeg", "sudah dipakai", archived: true)
      city = {
        "slug" => "kota-arsip",
        "nama_kota" => "Kota Arsip",
        "tanggal" => "2026-11-26",
        "foto_source" => "sudah-terpakai/arsip.jpeg"
      }

      assert_raises(CityPostGenerator::ArchivedSourceError) do
        CityPostGenerator.generate(city, root: root)
      end
      refute File.exist?(File.join(root, "_post_with_city"))
      refute File.exist?(File.join(root, "scripts/data/image-provenance.jsonl"))
    end
  end

  private

  def write_photo(root, relative, content, archived: false)
    dir = File.join(root, "source-image")
    dir = File.join(dir, "sudah-terpakai") if archived
    FileUtils.mkdir_p(dir)
    File.write(File.join(dir, relative), content)
  end
end
