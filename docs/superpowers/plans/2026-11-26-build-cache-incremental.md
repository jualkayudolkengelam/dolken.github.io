# Build Cache Inkremental Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Memangkas waktu `./rebuild.sh build` dari ~12 detik menjadi ~2 detik untuk build hangat tanpa mengubah HTML yang dihasilkan.

**Architecture:** Logika checksum ditempatkan di modul Ruby `BuildCache` agar mudah diuji. `rebuild.sh` memanggilnya sebelum build; jika input bersama berubah, cache Jekyll dihapus supaya regenerasi penuh terjadi. Jekyll `--incremental` menangani per-artikel lewat mtime, sementara checksum kita menangani file yang tidak dilacak Jekyll.

**Tech Stack:** Bash (`rebuild.sh`), Ruby 3.x + Minitest, Jekyll 4.3.4, `sha256sum` tidak dipakai langsung (hash dihitung dengan `Digest::SHA256`).

**Spec:** `docs/DESAIN-CACHE-BUILD.md`

## Global Constraints

- Tag rollback `pre-build-cache-2026-11-26` sudah ada di commit `bd1be5026f64203d4753775127d02c4ae1a11f74`, lokal dan di `origin`. Jangan hapus atau pindahkan tag ini.
- Jangan mengubah 74 artikel di `_post_with_city/`, field frontmatter, timestamp UTC, WebP, atau `scripts/data/image-provenance.jsonl`.
- `source-image/` termasuk `sudah-terpakai/` tetap gitignored dan tidak ter-commit.
- Perintah `serve` di `rebuild.sh` tidak boleh diubah.
- `clean-build` harus tetap menghasilkan build penuh tanpa flag `--incremental`.
- Semua perubahan harus lolos test yang sudah ada sebelum commit.

## Review Focus

- Perubahan `_data/area_pengiriman.yml` tidak boleh memakai HTML lama → diuji di Task 1 (`test_signature_berubah_saat_file_data_diubah`).
- Penambahan atau penghapusan artikel harus memicu regenerasi halaman indeks/sitemap → diuji di Task 1 (`test_signature_berubah_saat_nama_artikel_bertambah`).
- Perubahan isi artikel tidak boleh mengubah signature (mtime Jekyll yang menangani) → diuji di Task 1 (`test_isi_artikel_tidak_mengubah_signature`).
- `build` harus memakai `--incremental`, `clean-build` tidak boleh memakainya → diuji di Task 2 (`test_build_memakai_incremental`, `test_clean_build_tanpa_incremental`).
- Hasil build inkremental harus identik dengan build penuh → diverifikasi di Task 3 dengan `diff -rq` setelah mengecualikan `sitemap.xml`, `feed.xml`, dan 5 halaman produk yang memakai `sample: 5` (pengacakan sudah ada sebelum perubahan ini).

---

### Task 1: Modul `BuildCache` dan test unit

**Files:**
- Create: `scripts/lib/build_cache.rb`
- Create: `test/test_build_cache.rb`
- Commit juga: `docs/DESAIN-CACHE-BUILD.md`, `docs/superpowers/plans/2026-11-26-build-cache-incremental.md`

**Interfaces:**
- Consumes: tidak ada.
- Produces:
  - `BuildCache.signature(root) -> String` (hex SHA-256)
  - `BuildCache.prepare(root:, cache_dir: ".jekyll-cache", metadata_file: ".jekyll-metadata") -> Symbol` (`:reset` atau `:reuse`)
  - CLI: `ruby scripts/lib/build_cache.rb prepare` mencetak `reset` atau `reuse`, memakai `Dir.pwd` sebagai root.

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/test_build_cache.rb` dengan struktur ini (lengkapi helper `make_root` seperti di bawah):

```ruby
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
```

- [ ] **Step 2: Jalankan test dan pastikan gagal**

Run: `ruby test/test_build_cache.rb`
Expected: FAIL dengan `cannot load such file -- .../scripts/lib/build_cache`

- [ ] **Step 3: Implementasi `scripts/lib/build_cache.rb`**

Definisikan konstanta:
- `SHARED_FILES = %w[Gemfile Gemfile.lock _config.yml _config_local.yml]`
- `SHARED_DIRS = %w[_data _includes _layouts _plugins assets/css assets/js]`
- `ARTICLE_DIRS = %w[_posts _post_with_city]`

`signature(root)` bangun string secara deterministik:
- untuk tiap path di `SHARED_FILES` yang `File.file?`, tambahkan `"F\t#{rel}\t#{Digest::SHA256.file(abs).hexdigest}\n"`
- untuk tiap file di `SHARED_DIRS` (rekursif, `File.file?`) yang diurutkan berdasarkan path relatif, tambahkan baris `F` yang sama
- untuk tiap `*.md` di `ARTICLE_DIRS` yang diurutkan berdasarkan path relatif, tambahkan `"N\t#{rel}\n"` (nama saja, bukan isi)
- kembalikan `Digest::SHA256.hexdigest(string)`

`prepare` baca `.jekyll-cache/build-inputs.sha256`; jika isinya sama dengan signature kembalikan `:reuse`. Jika berbeda atau tidak ada: `FileUtils.rm_rf` cache dir, `FileUtils.rm_f` metadata file, `mkdir_p` cache dir, tulis signature + newline, kembalikan `:reset`.

Tambahkan CLI di bawah file: jika `$PROGRAM_NAME == __FILE__` dan `ARGV[0] == "prepare"`, cetak hasil `BuildCache.prepare(root: Dir.pwd)`.

- [ ] **Step 4: Jalankan test dan pastikan hijau**

Run: `ruby test/test_build_cache.rb`
Expected: `5 runs, ... assertions, 0 failures, 0 errors`

- [ ] **Step 5: Commit**

```bash
git add docs/DESAIN-CACHE-BUILD.md \
        docs/superpowers/plans/2026-11-26-build-cache-incremental.md \
        scripts/lib/build_cache.rb test/test_build_cache.rb
git commit -m "feat: add build input signature and cache reset helper"
```

---

### Task 2: Pasang ke `rebuild.sh`

**Files:**
- Modify: `rebuild.sh:74-99` (`build_site`)
- Modify: `rebuild.sh:188-200` (`main`)
- Create: `test/test_rebuild_cache.rb`

**Interfaces:**
- Consumes: `ruby scripts/lib/build_cache.rb prepare` dari Task 1 (mencetak `reset`/`reuse`).
- Produces: `build` memanggil `bundle exec jekyll build ... --future --incremental`; `clean-build` memanggil perintah yang sama tanpa `--incremental`.

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/test_rebuild_cache.rb` dengan `require "open3"`, `require "fileutils"`, `require "minitest/autorun"`, `require "tmpdir"` dan dua test `test_build_memakai_incremental` serta `test_clean_build_tanpa_incremental`. Helper `isolated_rebuild` harus:
- menyalin `rebuild.sh` dan `scripts/lib/build_cache.rb` ke direktori `tmp/repo`
- menulis `_config.yml` minimal di sana
- membuat `tmp/bin/bundle` berisi:

```bash
#!/bin/bash
printf '%s\n' "$@" > "$CAPTURE"
```

- menjalankan `Open3.capture3` dengan env `HOME => tmp`, `PATH => "#{tmp}/bin:#{ENV.fetch('PATH')}"`, `CAPTURE => capture_path`, `chdir => tmp/repo`, argumen `["bash", "rebuild.sh", command]`
- mengembalikan `File.readlines(capture_path).map(&:chomp)`

Assertions:
- `test_build_memakai_incremental`: `assert_equal "build", args.first`, `assert_includes args, "--future"`, `assert_includes args, "--incremental"`
- `test_clean_build_tanpa_incremental`: `assert_equal "build", args.first`, `assert_includes args, "--future"`, `refute_includes args, "--incremental"`

- [ ] **Step 2: Jalankan test dan pastikan gagal**

Run: `ruby test/test_rebuild_cache.rb`
Expected: FAIL karena belum ada `--incremental`

- [ ] **Step 3: Ubah `rebuild.sh`**

Di `build_site()`, terima argumen kedua `local mode="${2:-incremental}"`. Jika `mode == "incremental"`, jalankan `ruby scripts/lib/build_cache.rb prepare` dan simpan hasilnya untuk `print_info`. Susun argumen build dengan array:

```bash
local build_args=(build --config "$config_file" --destination "$OUTPUT_DIR" --future)
[[ "$mode" == "incremental" ]] && build_args+=(--incremental)
if bundle exec jekyll "${build_args[@]}"; then ...
```

Di `main()`, ubah:
- `build) build_site "$config" incremental ;;`
- `clean-build|rebuild) clean_build; build_site "$config" full ;;`

Biarkan `serve|server` apa adanya.

- [ ] **Step 4: Jalankan test dan pastikan hijau**

Run: `ruby test/test_rebuild_cache.rb`
Expected: `2 runs, ... assertions, 0 failures, 0 errors`

- [ ] **Step 5: Commit**

```bash
git add rebuild.sh test/test_rebuild_cache.rb
git commit -m "feat: use incremental Jekyll build with cache guard"
```

---

### Task 3: Verifikasi penuh dan penutupan

**Files:**
- Tidak ada file baru. Perbaiki apa pun yang gagal di verifikasi di task yang bersangkutan, lalu amend/commit perbaikan tersebut.

**Interfaces:**
- Consumes: perilaku `build` dan `clean-build` dari Task 2.
- Produces: bukti bahwa output inkremental sama dengan output penuh dan seluruh suite hijau.

- [ ] **Step 1: Jalankan seluruh test Ruby**

Run: `for f in test/test_*.rb; do ruby "$f" || exit 1; done`
Expected: semua file test exit 0, termasuk 15 file test setelah Task 1 dan 2.

- [ ] **Step 2: Jalankan validator yang sudah ada**

Run:
```bash
ruby scripts/validate-post-timestamps.rb
./validate-post.sh _post_with_city/*.md
```
Expected: `OK: 74 artikel, timestamp UTC unik` dan 74 baris `OK:`.

- [ ] **Step 3: Bandingkan output build penuh dan inkremental**

Run:
```bash
G=/home/aapanel/.local/share/gem/ruby/3.3.0/ruby/3.3.0
export GEM_HOME="$G" GEM_PATH="$G:/var/lib/gems/3.3.0" PATH="$G/bin:$PATH"
D=/tmp/opencode/build-cache-verify
rm -rf "$D"; mkdir -p "$D/full" "$D/inc"
bundle exec jekyll build --future --destination "$D/full"
cp -a "$D/full/." "$D/inc/"
bundle exec jekyll build --future --incremental --destination "$D/inc"
diff -rq --exclude=sitemap.xml --exclude=feed.xml "$D/full" "$D/inc" > "$D/diff.txt" || true
grep -v -E 'product/kayu-dolken-(10-14cm|2-3cm|3-5cm|5-7cm|8-10cm)/index\.html' "$D/diff.txt" || true
```
Expected: tidak ada baris selain 5 halaman produk tersebut. `sitemap.xml` dan `feed.xml` dikecualikan karena memakai waktu build; 5 halaman produk dikecualikan karena `_includes/products/block--product-area-pengiriman.html` memakai `sample: 5` dan mengacak daftar kota pada setiap build penuh.

- [ ] **Step 4: Ukur build hangat**

Run `./rebuild.sh build` dua kali berturut-turut, catat baris `done in ... seconds`. Expected: build kedua lebih cepat secara nyata dari build pertama (target ~2 detik).

- [ ] **Step 5: Cek kebersihan repo**

Run:
```bash
git diff --check
git status --short --branch
git ls-files .jekyll-cache .jekyll-metadata
```
Expected: `diff --check` bersih, tidak ada file cache yang ter-track, working tree bersih setelah commit terakhir.

- [ ] **Step 6: Commit perbaikan bila ada**

```bash
git add -A && git commit -m "fix: address build cache verification findings"
```
Lewati langkah ini bila tidak ada perbaikan.
