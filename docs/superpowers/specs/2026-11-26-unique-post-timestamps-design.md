# Desain: Timestamp frontmatter unik per artikel kota

## Maksud

Ke-26 artikel di `_post_with_city/` punya `date` dan `last_modified_at` yang unik per artikel, ditulis dalam UTC dengan presisi sampai detik, dan terasa seperti waktu terbit/sunting yang wajar. `jekyll-sitemap` memakai `last_modified_at` untuk `<lastmod>` (fallback `date`); include schema memakai `date`/`last_modified_at` untuk `datePublished`/`dateModified`.

## Fakta dan batasan

- Konten pertama di repo: `2025-12-11`; sekarang `2026-11-26`. Nama file artikel kota berkisar `2025-11-15`–`2026-11-26`.
- Tanggal commit **tidak** dipakai sebagai dasar frontmatter; tanggal commit dan tanggal frontmatter memang tidak harus sama.
- Spike Jekyll: permalink dibentuk dari **tanggal kalender `date`**, bukan dari nama file. `date: '2026-11-25 17:00:00 +0000'` memindahkan artikel ke `/blog/2026/11/25/...`. Jadi tanggal kalender `date` harus sama dengan tanggal di nama file; keunikan dicapai lewat jam/menit/detik.

## Tujuan

- `date` dan `last_modified_at` unik lintas 26 artikel, berformat UTC berkutip dengan detik, misalnya `'2026-11-26 03:17:42 +0000'`.
- Jam terbit tersebar di jam kerja, bukan semua tengah malam berurutan.
- `last_modified_at` lebih lambat dari `date` dan tidak melewati waktu sekarang.
- Validator menolak format bukan UTC/tanpa detik, duplikat, tanggal yang tidak cocok dengan nama file, serta lastmod sebelum date.
- Generator masa depan memakai algoritma yang sama.

## Bukan tujuan

- Mengubah body, gambar, provenance, atau URL artikel; menambah field baru di luar 39 field kanonik.
- Mengubah halaman, produk, dan artikel `_posts/` di luar koleksi `post_with_city`.
- Mengklaim artikel baru terbit berbulan-bulan lalu; tanggal kalender tetap mengikuti nama file.

## Pendekatan yang dipilih

1. Untuk setiap artikel, `date` = tanggal kalender dari nama file pukul `08:00`–`12:30` WIB (=`01:00`–`05:30` UTC pada tanggal yang sama), dengan slot menit/detik ditentukan deterministik dari SHA-256 slug.
2. `last_modified_at` = `date` + 1–3 jam (jeda juga dari hash slug), jadi maksimal `15:30` WIB untuk artikel hari ini — masih sebelum `2026-11-26 16:55 WIB`.
3. Bila slot dari hash bertabrakan dengan artikel lain, detik digeser satu per satu sampai unik. Proses dilakukan berurutan berdasarkan nama file agar hasil dapat diulang.
4. `scripts/lib/post_timestamps.rb` adalah satu-satunya sumber aturan ini; dipakai migrasi, generator, validator, dan test.
5. `scripts/validate-post-timestamps.rb` memeriksa seluruh koleksi dan keluar 1 bila ada pelanggaran.
6. `test/test_post_timestamps.rb` dibuat RED dulu (sebelum modul ada), lalu GREEN.

## Alternatif yang tidak dipilih

- **Detik berurutan tengah malam** — unik, tapi jelas buatan.
- **Tanggal commit sebagai dasar** — tidak diperlukan dan tidak selalu sesuai dengan tanggal konten.
- **Sebar tanggal sepanjang 2025-12-11…2026-11-26** — mengubah permalink/arsip atau memaksa field `permalink` ke-40, serta menyatakan artikel baru terbit sebelum file-nya ada.
- **Tambah field `permalink`** — menjaga URL lama sambil menggeser `date`, tetapi keluar dari skema 39 field.

## Verifikasi

- Test baru RED dulu, lalu GREEN; seluruh suite hijau.
- `validate-post.sh --new` dan validator timestamp lolos untuk 26 artikel.
- Build Jekyll `--future` exit 0; 26 URL sama persis seperti sebelum revisi; `<lastmod>` di `sitemap.xml` unik untuk 26 URL itu; `datePublished`/`dateModified` unik, UTC, dan tidak di masa depan.
- `git status`: hanya frontmatter, generator, validator, test, dan dokumen yang berubah; gambar/provenance tidak berubah.
