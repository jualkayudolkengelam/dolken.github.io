# Desain: Rapikan frontmatter 6 artikel kota existing

## Intent

Enam artikel di `_post_with_city/` sudah tayang tetapi belum memenuhi skema kanonik 39 field. Pemilik situs meminta perbaikan konten existing, termasuk Gowa, agar sesuai standar yang dipakai generator dan validator baru.

## Goals

- keenam artikel memiliki tepat 39 field kanonik sehingga `./validate-post.sh <file>` tidak menghasilkan warning;
- tidak ada fakta lokal baru yang mengarang — setiap nilai diambil dari artikel yang bersangkutan atau dari pola artikel Gowa/Makassar yang sudah ada;
- narasi, gambar, dan field ekstra yang dipakai template tetap utuh;
- perubahan di-commit langsung ke `main` (izin sudah diberikan pemilik).

## Non-goals

- tidak mengubah isi body artikel atau path gambar;
- tidak menambah/menghapus provenance, tidak memaksa mode `--new` pada artikel lama;
- tidak mengurangi 2 gambar Gowa/Makassar menjadi 1;
- tidak membuat artikel kota baru.

## Constraints

- skema kanonik = 39 field dari `CityPostSchema::REQUIRED_FIELDS`;
- `block_keunggulan_gelam` dipakai `_includes/reusable/post-with-city/block--keunggulan-kayu-dolken-gelam.html`, `total_updates` dipakai skrip engagement, dan `url` ada di artikel Semarang — ketiganya dipertahankan;
- Gowa dan Makassar tetap memiliki 2 gambar (status legacy).

## Approaches

1. **Isi field yang hilang saja** — nilai diambil dari artikel masing-masing. Risiko paling rendah; validator default bersih tanpa menyentuh konten tayang. **Dipilih.**
2. Isi field yang hilang dan hapus field ekstra — skema lebih bersih, tetapi berisiko merusak include dan skrip yang masih membaca field tersebut.
3. Generate ulang keenam artikel dari `source-image/` — menghasilkan 1 gambar + provenance, tetapi mengubah aset dan narasi yang sudah tayang serta memerlukan data lokal baru.

## Nilai yang akan ditambahkan

| Artikel | Field | Sumber nilai |
|---|---|---|
| Semarang | `author_url` | `https://jualkayudolken.com` (sama seperti Gowa/Makassar) |
| Semarang | `keunggulan_kayu_dolken` | salinan kartu `keunggulan_produk` Semarang yang sudah memuat konteks lokal |
| Terdekat, Bandung, Karawang | `author_url` | `https://jualkayudolken.com` |
| Terdekat, Bandung, Karawang | `keunggulan_durabilitas` | hash `tahan_lama`, `anti_rayap`, `tahan_cuaca`, `kuat_padat` dari kartu `keunggulan_kayu_dolken` masing-masing |
| Terdekat, Bandung, Karawang | `keunggulan_nilai` | hash `ramah_lingkungan`, `estetika` dari kartu kelima dan keenam masing-masing |
| Terdekat | `last_modified_at` | `2025-11-15` (tanggal artikel) |
| Bandung, Karawang | — | sudah punya `last_modified_at` |
| Gowa | `like_count` | `0` (netral, sama seperti Makassar; tidak ada data engagement nyata) |
| Makassar | `excerpt` | salinan `description` Makassar |
| Makassar | `last_modified_at` | `2026-06-28` (tanggal artikel) |

## Verifikasi

- test regresi: keenam artikel memiliki `CityPostSchema.missing_fields(...) == []` dan `./validate-post.sh <file>` exit 0 tanpa `WARNING`;
- `bundle exec jekyll build --future` tetap sukses;
- `git diff` hanya menunjukkan penambahan baris frontmatter, bukan perubahan body.

## Yang tersisa untuk implementer

Menyisipkan 15 field ke 6 file dengan edit terarah, menjalankan test regresi dan build, lalu commit ke `main`.
