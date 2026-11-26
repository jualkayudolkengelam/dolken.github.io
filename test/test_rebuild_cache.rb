# frozen_string_literal: true

require "fileutils"
require "minitest/autorun"
require "open3"
require "tmpdir"

class RebuildCacheTest < Minitest::Test
  def test_build_memakai_incremental
    args = isolated_rebuild("build")
    assert_equal %w[exec jekyll build], args[0..2]
    assert_includes args, "--future"
    assert_includes args, "--incremental"
  end

  def test_clean_build_tanpa_incremental
    args = isolated_rebuild("clean-build")
    assert_equal %w[exec jekyll build], args[0..2]
    assert_includes args, "--future"
    refute_includes args, "--incremental"
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
      File.readlines(capture).map(&:chomp)
    end
  end
end
