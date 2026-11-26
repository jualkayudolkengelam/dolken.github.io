# Desain: Pilot 3 artikel kota baru dengan default netral

## Intent

Pemilik situs ingin menambah artikel `post_with_city` untuk kota di Banten, DKI, Jawa, Bali, dan Sulawesi Selatan. Sebelum produksi massal, dibuat pilot 3 kota untuk memvalidasi template. Isi tidak boleh mewarisi fakta Gowa dari `city-defaults.yml`.

## Keputusan pemilik

- Kota pilot: **Tangerang, Surabaya, Denpasar** (Bandung, Semarang, Gowa, Makassar dilewati karena sudah ada).
- Konten: **netralisasi default** — tidak mengarang luas, populasi, kecamatan, landmark, atau testimoni lokal.
- Tanggal terbit: **2026-11-26** untuk ketiganya.

## Goals

- `city-defaults.yml` tidak lagi memuat nama tempat, angka demografi, atau kutipan yang spesifik untuk Gowa/Makassar/Sulawesi Selatan.
- 3 artikel baru dibuat lewat generator: 39 field kanonik, tepat 1 WebP, provenance SHA-256 dari `source-image/`.
- Validator mode `--new` lolos; build Jekyll sukses; tidak ada placeholder atau sisa nama kota lama.

## Non-goals

- Tidak membuat 17 kota lainnya sekarang (menunggu hasil pilot).
- Tidak menambah data lokal per kota dari sumber eksternal — itu akan diputuskan setelah pilot.
- Tidak mengubah 6 artikel existing, include/layout, atau skema 39 field.
- Tidak meng-commit `source-image/`.

## Constraints

- `CityPostSchema::REQUIRED_FIELDS` tetap 39 field.
- `CityProfile.substitute` hanya mengenali token `{{nama_kota}}`, `{{slug}}`, `{{tanggal}}`; semua token lain akan terdeteksi sebagai placeholder oleh validator.
- Include yang memakai data: `block--area-pengiriman-kayu-dolken.html`, `block--tentang-kota-kami.html`, `block--studi-kasus-proyek.html`, `block--testimoni-pelanggan.html`, `block--relevansi-kayu-dolken.html`. Struktur nested array/hash harus tetap sama agar include tidak kosong.
- Generator menolak menimpa artikel/gambar yang sudah ada; mode `--dry-run` tidak menulis apa pun.

## Perubahan pada `city-defaults.yml`

1. Semua nama tempat dan klaim lokal diganti teks generik berbasis `{{nama_kota}}`:
   - `area_pengiriman`: zona umum (pusat, utara, selatan, timur, barat, industri, perumahan, komersial, pendidikan).
   - `area_pengiriman_detail`: judul/deskripsi generik; `wilayah_pusat`, `wilayah_utara_selatan`, `wilayah_pengembangan` memakai nama zona umum; `landmark_wisata`/`landmark_fasilitas` memakai label generik seperti "Taman Kota {{nama_kota}}".
   - `keunggulan_*`, `aplikasi_kayu_dolken`, `faq_*`, `relevansi_kayu_dolken`, `tentang_kota`: narasi produk tanpa nama kota/ukuran/populasi tertentu.
   - `studi_kasus_proyek` dan `testimoni_*`: lokasi dan nama diganti label generik `{{nama_kota}}` agar tidak menyiratkan pelanggan nyata di kota tertentu.
2. Teks instruksi template yang tersisa di `finalisasi_pengiriman` ("tulis…", "jelaskan…", "mention…") diganti kalimat customer-facing.
3. Bereskan konten rusak: `在哪里买的`, `sakbis`, dan duplikat "Developer perumahan".

## Profil kota (`scripts/data/city-profiles.yml`)

```
cities:
  - slug: tangerang
    nama_kota: Tangerang
    tanggal: "2026-11-26"
    foto_source: <dipilih dari source-image/>
  - slug: surabaya
    nama_kota: Surabaya
    tanggal: "2026-11-26"
    foto_source: <dipilih dari source-image/>
  - slug: denpasar
    nama_kota: Denpasar
    tanggal: "2026-11-26"
    foto_source: <dipilih dari source-image/>
```

`overrides` tidak diisi pada pilot; seluruh nilai berasal dari default netral. Foto dipilih satu per kota dari `source-image/` (boleh berbeda file, tidak boleh duplikat hash dalam satu artikel).

## Verifikasi

- `grep` terhadap `city-defaults.yml` dan 3 artikel: tidak ada `Sungguminasa|Malino|Makassar|Gowa|Sulawesi|Sulsel|Pallangga|Biringbulu|...` maupun placeholder `{{...}}`/`{NAMA_KOTA}`.
- `ruby scripts/generate-city-post.rb --dry-run` → 3 path artikel tercetak, tanpa file baru.
- `./validate-post.sh --new` pada 3 artikel → 0 error.
- `bundle exec jekyll build --future` → exit 0.
- `git status`: hanya `city-defaults.yml`, `city-profiles.yml`, 3 artikel, 3 WebP, dan `image-provenance.jsonl` yang berubah/baru; `source-image/` tetap tidak ter-commit.

## Yang tersisa untuk implementer

Menulis default netral, mengisi profil 3 kota, menjalankan dry-run → generate → validasi → build → commit → push `main`.
