# Cara Menambah Artikel Kota

Panduan ini menghasilkan artikel `post_with_city` dengan struktur 39 field, tepat satu gambar WebP, dan catatan provenance SHA-256. Jalankan semua perintah dari root repository.

## 1. Isi profil kota

Tambahkan entri ke bagian `cities:` di `scripts/data/city-profiles.yml`:

```yaml
defaults: {}
cities:
  - slug: bogor
    nama_kota: Bogor
    tanggal: "2026-12-01"
    foto_source: "nama-foto.jpeg"
    # overrides opsional, misalnya:
    # overrides:
    #   title: "Judul khusus kota"
```

- `slug`: huruf kecil dan angka, dipisahkan tanda `-` jika lebih dari satu kata. Dipakai untuk nama file artikel dan direktori gambar.
- `nama_kota`: nama kota yang ditampilkan di artikel.
- `tanggal`: tanggal terbit `YYYY-MM-DD`.
- `foto_source`: path relatif terhadap direktori `source-image/`. Semua gambar artikel **wajib** berasal dari sana.
- `overrides`: opsional, menimpa nilai default kanonik secara nested.

### Wajib review konten spesifik kota

Nilai default sudah dinetralisasi: tidak memuat kecamatan, luas, populasi, atau landmark Gowa. Nama testimoni memakai nama orang Indonesia fiktif yang netral, dengan lokasi `{{nama_kota}}`. Isi `overrides` hanya jika Anda memiliki data lokal yang benar untuk kota tersebut:

- `area_pengiriman`, `area_pengiriman_detail` — kecamatan dan wilayah pengiriman yang sebenarnya.
- `tentang_kota` — luas, populasi, batas wilayah, dan landmark yang sebenarnya.
- `testimoni_komersial`, `testimoni_residential`, `studi_kasus_proyek` — nama dan lokasi pelanggan nyata bila tersedia; jangan mengarang.
- `faq_pemesanan`, `faq_pengiriman`, `faq_produk`, `tips_ukuran`, `aplikasi_kayu_dolken` — konteks lokal bila tersedia.
- `title`, `description`, `excerpt`, `keywords` — pastikan tidak menyisakan nama kota lama.

Review manual terhadap artikel yang dihasilkan tetap wajib sebelum commit.

## 2. Uji dulu dengan dry-run

```bash
ruby scripts/generate-city-post.rb --profile scripts/data/city-profiles.yml --dry-run
```

Dry-run tidak menulis artikel, gambar, maupun provenance. Periksa slug dan tanggal yang tercetak sebelum melanjutkan.

## 3. Generate artikel dan gambar

```bash
ruby scripts/generate-city-post.rb --profile scripts/data/city-profiles.yml
```

Generator menolak menimpa artikel atau gambar yang sudah ada. Gunakan `--slug <slug>` untuk hanya memproses satu kota.

## 4. Validasi artikel baru

```bash
./validate-post.sh --new _post_with_city/2026-12-01-jual-kayu-dolken-bogor.md
```

Mode `--new` ketat: field kanonik harus lengkap, tidak ada placeholder, gambar harus ada, dan hash gambar harus memiliki provenance dari `source-image/`.

## 5. Build situs

```bash
./rebuild.sh build
```

## 6. Periksa dan commit

Baca artikel hasil generate dan pastikan tidak ada lagi fakta kota lama sebelum commit.

```bash
git status
git add _post_with_city/2026-12-01-jual-kayu-dolken-bogor.md \
        assets/images/posts/jual-kayu-dolken-bogor/ \
        scripts/data/image-provenance.jsonl
git commit -m "post: tambah artikel kota Bogor"
```

`source-image/` sengaja tidak ikut di-commit (terdaftar di `.gitignore`).

## Aturan gambar

- Foto yang sama **boleh** dipakai ulang di kota lain.
- Hash gambar yang sama **tidak boleh** muncul dua kali dalam satu artikel; generator dan validator akan menolaknya.
- Setiap gambar artikel harus berasal dari file di dalam `source-image/` dan dikonversi ke WebP oleh generator.
