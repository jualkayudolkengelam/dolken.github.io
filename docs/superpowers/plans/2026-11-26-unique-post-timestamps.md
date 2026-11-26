# Rencana: Timestamp frontmatter unik per artikel kota

## Konteks

Lihat `docs/superpowers/specs/2026-11-26-unique-post-timestamps-design.md`. Tanggal kalender `date` = tanggal nama file (URL aman); keunikan dan kesan natural berasal dari jam/menit/detik yang tersebar. Tanggal commit tidak dipakai.

## Task 1 — Test RED

Buat `test/test_post_timestamps.rb` yang `require_relative "../scripts/lib/post_timestamps"` dan berisi:

- ke-26 artikel lolos `PostTimestamps.validate(root: ROOT)`;
- validator menolak duplikat `date`, format tanpa detik/offset `+0700`, `last_modified_at < date`, dan tanggal yang tidak cocok dengan nama file;
- `format`/`parse` round-trip dan `next_unique` melewati nilai terpakai;
- `natural_times` deterministik, berada di jendela `01:00`–`05:30` UTC, dan lastmod lebih lambat;
- `allocate` menghindari nilai yang sudah dipakai (stub `natural_times`).

Jalankan: RED (LoadError) sebelum modul dibuat.

## Task 2 — `scripts/lib/post_timestamps.rb`

- `FIELDS`, `FORMAT = "%Y-%m-%d %H:%M:%S +0000"`, `PATTERN`.
- `Result(errors:) { success? }`.
- `format(time)`, `parse(value)` (hanya String UTC berdetik), `legacy_time(value)` (dipakai hanya untuk membaca nilai lama saat migrasi: tanggal tanpa jam → UTC tengah malam; offset eksplisit → UTC).
- `articles(root)`, `frontmatter(path)`, `used_values(root)`.
- `next_unique(base, used)` — +1 detik sampai bebas.
- `natural_times(slug:, tanggal:)` — SHA-256 slug untuk slot `08:00`–`12:30` WIB dan jeda 1–3 jam; hasil `[publish_utc, modified_utc]`.
- `allocate(root:, slug:, tanggal:)` — `next_unique` terhadap semua artikel yang ada.
- `validate(root:)` — field hilang/format salah/parse gagal/duplikat/lastmod sebelum date/tanggal tidak cocok nama file.
- `rewrite_article(path:, date:, modified:)` — menimpa dua baris frontmatter saja, dipakai migrasi.

## Task 3 — CLI `scripts/validate-post-timestamps.rb`

Tanpa argumen (opsional `--root PATH`) mencetak `OK: <n> artikel, timestamp unik` atau error ke stderr; exit 1 bila gagal.

## Task 4 — Migrasi `scripts/migrate-post-timestamps.rb`

Untuk tiap artikel terurut berdasarkan nama file: `slug` dari nama file, `tanggal` dari nama file, lalu `date, modified = PostTimestamps.allocate(...)` dan `rewrite_article`. Jalankan sekali; `git diff` hanya dua baris per artikel. Tidak ada pembacaan git.

## Task 5 — Generator

Di `CityPostGenerator.generate`, setelah `merged = CityProfile.merge(...)`:

```ruby
date, modified = PostTimestamps.allocate(root: root, slug: slug, tanggal: city.fetch("tanggal"))
merged["date"] = date
merged["last_modified_at"] = modified
```

`dry_run` tidak menulis. Nama file, `tanggal` profil, gambar, dan provenance tidak berubah.

## Task 6 — Verifikasi & integrasi

- Test baru GREEN; seluruh `test/test_*.rb` hijau.
- `ruby scripts/validate-post-timestamps.rb` exit 0; `validate-post.sh --new` 26 artikel OK.
- Build Jekyll `--future` ke `/tmp/opencode/jekyll-timestamps`: 26 URL sama; `<lastmod>` unik; HTML `datePublished`/`dateModified` unik, UTC, tidak masa depan.
- Perbarui `docs/CARA-TAMBAH-KOTA.md` dengan aturan timestamp + validator baru.
- Commit dan push ke `main`.
