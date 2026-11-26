# Rencana: Rapikan frontmatter 6 artikel kota existing

Dibuat dari `docs/superpowers/specs/2026-11-26-fix-existing-city-posts-design.md`.
Eksekutor diasumsikan belum pernah melihat repo ini; semua path dan nilai penting ada di bawah.

## Konteks singkat

- Root repo: `/www/wwwroot/jualkayudolken`, branch `main`.
- Enam artikel di `_post_with_city/` belum memenuhi 39 field kanonik (`CityPostSchema::REQUIRED_FIELDS` di `scripts/lib/city_post_schema.rb`).
- Validator: `./validate-post.sh <file>` menjalankan `scripts/validate-city-post.rb` (mode default → field hilang jadi `WARNING`, exit 0).
- Perbaikan hanya menambah field; body, gambar, dan field ekstra (`url`, `total_updates`, `block_keunggulan_gelam`) tidak disentuh.

## Task 1 — Test regresi (RED)

**File:** `test/test_existing_city_posts.rb` (baru)

- `require "minitest/autorun"`, `require_relative "../scripts/lib/city_post_schema"`, `require_relative "../scripts/validate-city-post"`.
-Konstanta `POSTS = Dir["_post_with_city/*.md"].sort` relatif terhadap root repo (test dijalankan dari root).
- Test `test_all_existing_posts_have_canonical_fields`: untuk tiap path, baca frontmatter dengan pola yang sama seperti validator (`YAML.safe_load(text[/\A---\n(.*?)\n---\n/m, 1], permitted_classes: [Date, Time], aliases: true)`), lalu `assert_empty CityPostSchema.missing_fields(fm), "…"`.
- Test `test_validator_reports_no_warnings`: `CityPostValidator.validate_file(File.expand_path(path), root: Dir.pwd)` lalu `assert_empty result.warnings` dan `assert_empty result.errors`.
- Jalankan `ruby test/test_existing_city_posts.rb` — **harus gagal** dengan daftar field hilang. Jangan lanjut sebelum gagal terlihat.
- Commit: `test: add regression for canonical city post frontmatter`.

## Task 2 — Semarang: `author_url`, `keunggulan_kayu_dolken`

**File:** `_post_with_city/2025-11-15-jual-kayu-dolken-semarang.md`

- Setelah baris `author: Admin` (sekitar baris 7) tambahkan `author_url: https://jualkayudolken.com` — sama seperti Gowa/Makassar.
- Sebelum `keunggulan_durabilitas:` (sekitar baris 30) tambahkan `keunggulan_kayu_dolken:` berisi 3 kartu hasil salinan `keunggulan_produk` Semarang (baris ~129):
  - `Judul: Kualitas Premium Grade A`, `deskripsi`: "Kayu gelam pilihan terbaik, secara alami tahan terhadap rayap dan cuaca ekstrem, ideal untuk kondisi iklim Semarang", `warna: warning`, `icon: bi-award-fill`
  - `Judul: Harga Terbaik`, `deskripsi`: "Beli langsung dari pemasok, harga dimulai dari Rp 15.000/batang tanpa biaya tambahan perantara", `warna: danger`, `icon: bi-cash-coin`
  - `Judul: Stok Selalu Ready`, `deskripsi`: "Stok lengkap dengan pilihan diameter dari 2-3 cm sampai 10-12 cm untuk berbagai keperluan proyek" → **gunakan teks asli persis dari `keunggulan_produk`**, jangan menerjemahkan.
- Commit: `fix: complete Semarang city post frontmatter`.

## Task 3 — Terdekat: 4 field

**File:** `_post_with_city/2025-11-15-jual-kayu-dolken-terdekat.md`

- Tambah `author_url: https://jualkayudolken.com` setelah `author: Admin` (baris ~18).
- Sebelum `keunggulan_produk:` (baris ~51) tambahkan:
  - `keunggulan_durabilitas:` dengan 4 kunci `tahan_lama`, `anti_rayap`, `tahan_cuaca`, `kuat_padat`, diisi dari 4 kartu pertama `keunggulan_kayu_dolken` (baris ~310), kalimat aslinya dipertahankan.
  - `keunggulan_nilai:` dengan 2 kunci `ramah_lingkungan`, `estetika`, diisi dari kartu ke-5 dan ke-6.
- Sebelum penutup `---` (setelah `share_count: 3`, baris ~690) tambahkan `last_modified_at: 2025-11-15` (tanggal artikel).
- Commit: `fix: complete Terdekat city post frontmatter`.

## Task 4 — Bandung & Karawang: 3 field each

**File:** `_post_with_city/2025-11-19-jual-kayu-dolken-bandung.md`

- `author_url: https://jualkayudolken.com` setelah `author: Admin`.
- `keunggulan_durabilitas` (4 kunci) + `keunggulan_nilai` (2 kunci) sebelum `keunggulan_produk:` (baris ~33), dari 6 kartu `keunggulan_kayu_dolken` (baris ~225).
- Commit: `fix: complete Bandung city post frontmatter`.

**File:** `_post_with_city/2025-11-19-jual-kayu-dolken-karawang.md`

- Perlakuan sama, kartu dari baris ~246, `keunggulan_produk:` di baris ~51.
- Commit: `fix: complete Karawang city post frontmatter`.

## Task 5 — Gowa & Makassar: 3 field total

**File:** `_post_with_city/2026-06-28-jual-kayu-dolken-gowa.md`

- Sebelum `comment_count: 12` (baris ~627) tambahkan `like_count: 0` (netral, mengikuti Makassar).
- Commit: `fix: add like_count to Gowa city post frontmatter`.

**File:** `_post_with_city/2026-06-28-jual-kayu-dolken-makassar.md`

- Setelah `description:` (baris ~16) tambahkan `excerpt:` dengan nilai persis `description` Makassar.
- Setelah `author_url:` (baris ~19) tambahkan `last_modified_at: 2026-06-28` (sama seperti Gowa).
- Commit: `fix: add excerpt and last_modified_at to Makassar city post frontmatter`.

## Task 6 — Verifikasi & integrasi (GREEN)

- `ruby test/test_existing_city_posts.rb` → 2 test hijau.
- `for f in test/test_*.rb; do ruby "$f" || exit 1; done` → seluruh suite hijau.
- `for f in _post_with_city/*.md; do ./validate-post.sh "$f"; done` → tidak ada baris `WARNING`.
- `bundle exec jekyll build --future --destination /tmp/opencode/jekyll-check-city-fix` → exit 0.
- `git diff --stat` → hanya penambahan baris frontmatter di 6 file + 1 file test.
- Push `main` ke origin ( PAT sudah tersedia di `~/.git-pat-kayu-dolken`; gunakan helper sementara dan redaksi output ).
- Commit terakhir bila perlu: `test: mark regression green after frontmatter normalization`.

## Catatan eksekusi

- Gunakan `edit` dengan konteks unik (nama field + baris sebelumnya) agar tidak mengubah body.
- Semua nilai `keunggulan_*` harus disalin persis dari artikel yang bersangkutan — jangan mengarang fakta lokal baru.
- Jangan hapus `url`, `total_updates`, atau `block_keunggulan_gelam`: masih dipakai template/include dan skrip engagement.
- Jangan memaksa mode `--new` pada artikel lama; Gowa/Makassar tetap 2 gambar tanpa provenance.
