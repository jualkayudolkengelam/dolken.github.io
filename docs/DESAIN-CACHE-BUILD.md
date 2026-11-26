# Desain: Cache Build Jekyll Inkremental

## Konteks dan pengukuran

Build penuh di repo ini memakan waktu ~12–13 detik setelah cache disk panas (32 detik saat dingin). Instrumentasi menunjukkan penulisan 236 file statis hanya memakan 0,113–0,232 detik, jadi penyalinan WebP bukanlah bottleneck. Build `--incremental` kedua selesai dalam 1,9 detik.

Isi build saat pengukuran: 103 file HTML, 83 file Markdown sumber, 122 file WebP, dan 102 URL di sitemap.

## Tujuan

- Memangkas waktu `./rebuild.sh build` untuk build hangat.
- Tidak mengubah artikel, timestamp, gambar, provenance, atau HTML yang dihasilkan.
- Menjamin perubahan file yang memengaruhi semua halaman tetap memicu regenerasi penuh.
- Menyediakan jalur rollback yang jelas.

## Non-tujuan

- Tidak mengubah `scripts/generate-city-post.rb`, `scripts/data/image-provenance.jsonl`, atau 74 artikel kota.
- Tidak mempercepat `clean-build`; perintah itu memang harus membangun dari nol.
- Tidak menyimpan checksum HTML output. HTML baru hanya tersedia setelah di-render, jadi checksum output tidak menghemat waktu render.

## Desain

Logika checksum ditempatkan di `scripts/lib/build_cache.rb` (modul `BuildCache`) agar bisa diuji terpisah dengan Minitest. `rebuild.sh` memanggilnya lewat `ruby scripts/lib/build_cache.rb prepare`, yang mencetak `reset` atau `reuse`.

`build_site()` menerima mode `incremental` (default) atau `full`:

1. Hitung `signature` = SHA-256 dari gabungan konten file bersama dan daftar nama file artikel:
   - `_config.yml`, `_config_local.yml` (jika ada)
   - `_data/**`, `_includes/**`, `_layouts/**`, `_plugins/**`
   - `assets/css/**`, `assets/js/**`
   - `Gemfile` dan `Gemfile.lock` (jika ada)
   - daftar nama (bukan isi) `_posts/*.md` dan `_post_with_city/*.md`, sudah diurutkan
2. Bandingkan `signature` dengan isi `.jekyll-cache/build-inputs.sha256`.
   - Jika berbeda atau file tidak ada: hapus `.jekyll-cache` dan `.jekyll-metadata`, lalu tulis `signature` yang baru.
3. Mode `incremental` menjalankan `bundle exec jekyll build --config "$config_file" --destination "$OUTPUT_DIR" --future --incremental`. Mode `full` menjalankan perintah yang sama tanpa `--incremental`.
4. `build` memakai mode `incremental`.
5. `clean-build` tetap memanggil `clean_build()` lebih dulu, lalu `build_site "$config" full`, sehingga benar-benar build penuh.
6. `serve` tidak diubah agar live-reload tetap berperilaku seperti sebelumnya.

## Kenapa checksum hanya untuk file bersama

`Regenerator` Jekyll sudah membandingkan mtime artikel dan mendaftarkan dependency untuk layout serta `{% include %}`. Namun ia **tidak** mendaftarkan `_data/` dan `_config.yml`, dan halaman indeks tidak otomatis di-render ulang saat artikel baru ditambahkan. Karena itu:

- isi artikel cukup ditangani mtime Jekyll;
- file bersama dan daftar nama artikel perlu checksum kita sendiri;
- perubahan apa pun pada keduanya membatalkan cache secara global.

## Verifikasi

- Tambah test shell untuk memastikan: signature stabil bila tidak ada perubahan; signature berubah saat file `_data/` diubah; signature berubah saat nama artikel ditambah; cache terhapus saat signature berubah.
- Bandingkan hasil build penuh dan build inkremental ke dua direktori berbeda. HTML dan sitemap harus identik, kecuali:
  - `sitemap.xml` dan `feed.xml` yang memakai waktu build;
  - 5 halaman produk yang memakai `sample: 5` di `_includes/products/block--product-area-pengiriman.html`. Daftar kota di halaman tersebut diacak ulang pada setiap build penuh, jadi sudah tidak identik bahkan sebelum perubahan ini. Build inkremental justru mempertahankan daftar yang terakhir dihasilkan.
- Jalankan ulang seluruh `test/test_*.rb`, `scripts/validate-post-timestamps.rb`, `validate-post.sh _post_with_city/*.md`, dan build Jekyll `--future`.
- Pastikan tidak ada berkas cache yang ter-commit dan `git status` bersih setelah commit.

## Risiko dan mitigasi

| Risiko | Mitigasi |
|---|---|
| Isi artikel berubah tetapi mtime tidak berubah (misalnya `git checkout` yang mempertahankan mtime) | Gunakan `clean-build` untuk deploy; `build` mengandalkan mtime Jekyll untuk artikel. |
| Plugin atau layout baru mengubah cara render | Semua file `_plugins/`, `_layouts/`, `_includes/` masuk dalam signature. |
| Perubahan Jekyll/Kubernetes mengubah perilaku inkremental | `Gemfile.lock` masuk signature; rollback ke tag di bawah. |

## Rollback

Tag `pre-build-cache-2026-11-26` dibuat di commit `bd1be5026f64203d4753775127d02c4ae1a11f74` dan sudah di-push ke `origin`. Untuk kembali ke kondisi sebelum perubahan ini:

```bash
git checkout pre-build-cache-2026-11-26 -- rebuild.sh
# atau, untuk membatalkan seluruh perubahan:
git reset --hard pre-build-cache-2026-11-26
```
