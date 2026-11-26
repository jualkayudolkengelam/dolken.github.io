# Spec: Penambahan Artikel Kota `post_with_city`

Disetujui oleh pengguna pada 2026-11-26.

## Tujuan

Menambah kota baru ke koleksi Jekyll `post_with_city` dengan struktur seragam, satu foto dari `source-image/`, tanpa duplikasi foto di dalam artikel, dan tervalidasi sebelum build.

## Keputusan

1. **Satu gambar per artikel baru**, dengan path `/assets/images/posts/jual-kayu-dolken-{slug}/jual-kayu-dolken-{slug}-001.webp`. Ini mengikuti mayoritas 6 artikel existing; template v2 yang meminta 4 gambar tidak dipakai. (Catatan: artikel Gowa dan Makassar memakai 2 gambar; artikel baru tetap 1.)
2. Setiap gambar artikel **wajib berasal dari `source-image/`**: di-copy, di-rename, lalu dikonversi ke WebP. Asal foto harus dapat ditelusuri lewat hash SHA-256.
3. Duplikasi gambar **di dalam satu artikel dilarang**. Pemakaian foto yang sama di kota lain dibolehkan.
4. Skema kanonik adalah **gabungan field Gowa + Makassar = 39 field**. Field di luar gabungan itu tidak ditambahkan.
5. Pendekatan: **generator Ruby + validator yang ditulis ulang**. `validate-post.sh` lama tidak dipakai sebagai dasar karena melaporkan 27 error pada artikel Bandung yang sudah tayang.
6. Konversi WebP memakai `ffmpeg` (`cwebp` dan Pillow tidak terpasang di lingkungan ini).

## Skema kanonik (39 field)

`aplikasi_kayu_dolken`, `area_pengiriman`, `area_pengiriman_detail`, `author`, `author_url`, `comment_count`, `date`, `description`, `excerpt`, `faq_pemesanan`, `faq_pengiriman`, `faq_produk`, `finalisasi_pengiriman`, `image`, `image_alt`, `images`, `images_alt`, `keunggulan_durabilitas`, `keunggulan_kayu_dolken`, `keunggulan_layanan`, `keunggulan_nilai`, `keunggulan_produk`, `keywords`, `last_modified_at`, `layout`, `like_count`, `nama_kota`, `proses_awal_pemesanan`, `rating`, `relevansi_kayu_dolken`, `review_count`, `share_count`, `show_products`, `studi_kasus_proyek`, `tentang_kota`, `testimoni_komersial`, `testimoni_residential`, `tips_ukuran`, `title`

## Komponen yang diharapkan

- `scripts/data/city-defaults.yml` — nilai kanonik 39 field, dengan token `{{nama_kota}}`, `{{slug}}`, `{{tanggal}}` untuk bagian yang spesifik kota.
- `scripts/data/city-post-body.md` — isi artikel standar (section + `{% include %}`) hasil ekstraksi artikel Gowa, dengan token `{{nama_kota}}` pada include `block--jual-kayu-dolken-terdekat.html`.
- `scripts/data/city-profiles.yml` — input pengguna: `slug`, `nama_kota`, `tanggal`, `foto_source` (path relatif di `source-image/`), dan `overrides` opsional untuk field kanonik mana pun.
- `scripts/lib/city_post_schema.rb` — definisi 39 field dan pemeriksaan field/placeholder.
- `scripts/lib/city_profile.rb` — pemuat dan validator profil, deep merge defaults + overrides.
- `scripts/generate-city-post.rb` — CLI generator dengan `--profile`, `--slug`, `--dry-run`; menyalin foto, konversi WebP, menulis artikel, dan mencatat provenance.
- `scripts/data/image-provenance.jsonl` — catatan `sha256`, source, output, slug, tanggal untuk setiap gambar yang dibuat generator.
- `scripts/validate-city-post.rb` — logika validasi, dua mode: default (legacy, toleran) dan `--new` (strict untuk artikel baru).
- `validate-post.sh` — wrapper tipis yang mempertahankan pemakaian `./validate-post.sh <file>`.
- `docs/CARA-TAMBAH-KOTA.md` — prosedur untuk pengguna.

## Gerbang akhir

`generate --dry-run` → `generate` → `validate-post.sh --new <file>` → build Jekyll → `git status`.

## Risiko & mitigasi

- Teks otomatis bisa terlalu generik → nilai default diberi token kota, dan `overrides` tersedia untuk kecamatan, landmark, dan testimoni; tetap wajib review manual sebelum commit.
- `source-image/` memuat satu pasangan file dengan hash SHA-256 identik → generator menolak bila dua file itu masuk dalam satu artikel.
- Validator lama memakai nama field yang berbeda → ditulis ulang, bukan dipatch.
- Artikel lama memiliki field kurang dari 39 dan `images_alt` tidak selalu sama jumlahnya dengan `images` → mode default melaporkan warning, bukan error; mode `--new` memberlakukan aturan ketat hanya untuk artikel baru.
