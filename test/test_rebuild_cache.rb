# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RebuildCacheTest < Minitest::Test
  def test_build_memakai_incremental
    result = isolated_rebuild("build")
    args = result[:args]
    assert_equal %w[exec jekyll build], args[0..2]
    assert_includes args, "--future"
    assert_includes args, "--incremental"
    assert result[:stamp_written], "build tidak menjalankan prepare"
  end

  def test_clean_build_tanpa_incremental
    result = isolated_rebuild("clean-build")
    args = result[:args]
    assert_equal %w[exec jekyll build], args[0..2]
    assert_includes args, "--future"
    refute_includes args, "--incremental"
    refute result[:stamp_written], "clean-build tidak boleh menulis stamp"
  end

  private

  def isolated_rebuild(command)
    Dir.mktmpdir do |tmp|
      repo = File.join(tmp, "repo")
      FileUtils.mkdir_p(File.join(repo, "scripts/lib"))
      FileUtils.cp(File.expand_path("../rebuild.sh", __dir__), File.join(repo, "rebuild.sh"))
      FileUtils.cp(File.expand_path("../scripts/lib/build_cache.rb", __dir__),
                   File.join(repo, "scripts/lib/build_cache.rb"))
      File.write(File.join(repo, "_config.yml"), "title: Contoh\n")

      bin = File.join(tmp, "bin")
      FileUtils.mkdir_p(bin)
      bundle = File.join(bin, "bundle")
      File.write(bundle, "#!/bin/bash\nprintf '%s\\n' \"$@\" > \"$CAPTURE\"\n")
      File.chmod(0o755, bundle)

      capture = File.join(tmp, "captured-args")
      env = {
        "HOME" => tmp,
        "PATH" => "#{bin}:#{ENV.fetch("PATH")}",
        "CAPTURE" => capture
      }
      _out, err, status = Open3.capture3(env, "bash", "rebuild.sh", command, chdir: repo)
      assert status.success?, "rebuild.sh gagal: #{err}"
      assert File.file?(capture), "bundle tidak dipanggil"
      {
        args: File.readlines(capture).map(&:chomp),
        stamp_written: File.file?(File.join(repo, ".jekyll-cache/build-inputs.sha256"))
      }
    end
  end
end
