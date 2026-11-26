# Penambahan Artikel Kota `post_with_city` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Menambah kota baru ke koleksi Jekyll `post_with_city` lewat generator dan validator yang menghasilkan artikel 39-field dengan satu gambar WebP unik dari `source-image/`.

**Architecture:** Generator Ruby membaca profil kota, menggabungkannya dengan default kanonik, menyalin satu foto dari `source-image/`, mengonversinya ke WebP dengan `ffmpeg`, lalu menulis Markdown dan catatan provenance SHA-256. Validator Ruby yang dipanggil melalui `validate-post.sh` memeriksa struktur, placeholder, path gambar, keunikan hash, dan provenance; mode `default` toleran pada artikel lama, mode `--new` ketat untuk artikel baru.

**Tech Stack:** Ruby 3.3.8, Minitest 5.20.0 (bundled), Jekyll 4.3, Bash, `ffmpeg` (libwebp), YAML, JSONL.

**Spec:** `docs/superpowers/specs/2026-11-26-tambah-kota-post-with-city.md`

## Global Constraints

- Gunakan tepat **1 gambar per artikel baru**, dengan path `/assets/images/posts/jual-kayu-dolken-{slug}/jual-kayu-dolken-{slug}-001.webp`.
- Gambar wajib berasal dari file di dalam `source-image/`; konversi ke `.webp` memakai `ffmpeg -c:v libwebp -quality 85`, lalu hapus file `.jpeg` hasil salinan.
- Skema kanonik = **39 field** seperti tercantum di spec. Jangan menambah field di luar daftar itu untuk artikel baru.
- Duplikasi hash gambar di dalam satu artikel = error. Pemakaian foto yang sama di kota lain = boleh.
- Generator tidak boleh menimpa file artikel atau file gambar yang sudah ada.
- Jangan push ke remote. Commit hanya seperti tertulis di tiap task.
- `test/` harus masuk daftar `exclude` di `_config.yml` agar tidak ikut terbit.

## Review Focus

- Dua foto identik dipilih dalam satu artikel → generator harus gagal sebelum menulis apa pun. Diuji di Task 3 Step 2.
- `foto_source` menunjuk ke luar `source-image/` atau file tidak ada → generator harus gagal tanpa membuat direktori/output. Diuji di Task 3 Step 3.
- Slug + tanggal yang sama digenerate dua kali → generator harus menolak menimpa artikel existing. Diuji di Task 3 Step 4.
- Artikel lama kekurangan field kanonik → validator mode default harus memberi warning, bukan error. Diuji di Task 4 Step 2.
- Build Jekyll tetap sukses setelah struktur baru dan folder `test/` ditambahkan → diuji di Task 5 Step 3.

---

### Task 1: Skema kanonik

**Files:**
- Create: `scripts/lib/city_post_schema.rb`
- Create: `test/test_city_post_schema.rb`

**Interfaces:**
- Consumes: tidak ada.
- Produces: `CityPostSchema::REQUIRED_FIELDS` (Array<String>, 39 nama field), `CityPostSchema::PLACEHOLDER_PATTERN` (Regexp), `CityPostSchema.missing_fields(fields) -> Array[String]`, `CityPostSchema.placeholders(fields) -> Array[String]`.

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/test_city_post_schema.rb` dengan assertions:
- `CityPostSchema::REQUIRED_FIELDS` sama persis dengan array 39 nama berikut (urutan diabaikan dengan `.sort`): `aplikasi_kayu_dolken`, `area_pengiriman`, `area_pengiriman_detail`, `author`, `author_url`, `comment_count`, `date`, `description`, `excerpt`, `faq_pemesanan`, `faq_pengiriman`, `faq_produk`, `finalisasi_pengiriman`, `image`, `image_alt`, `images`, `images_alt`, `keunggulan_durabilitas`, `keunggulan_kayu_dolken`, `keunggulan_layanan`, `keunggulan_nilai`, `keunggulan_produk`, `keywords`, `last_modified_at`, `layout`, `like_count`, `nama_kota`, `proses_awal_pemesanan`, `rating`, `relevansi_kayu_dolken`, `review_count`, `share_count`, `show_products`, `studi_kasus_proyek`, `tentang_kota`, `testimoni_komersial`, `testimoni_residential`, `tips_ukuran`, `title`.
- `CityPostSchema.missing_fields({})` mengembalikan ke-39 nama itu.
- `CityPostSchema.missing_fields({"nama_kota"=>"Bogor","title"=>"x"})` mengembalikan 37 nama tanpa `nama_kota` dan `title`.
- `CityPostSchema.placeholders({"title"=>"Jual {{nama_kota}}", "description"=>"{NAMA_KOTA}"})` mengembalikan `["title","description"]`.
- `CityPostSchema.placeholders({"title"=>"Jual Kayu Dolken Bogor"})` mengembalikan `[]`.

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

Run: `ruby test/test_city_post_schema.rb`
Expected: FAIL karena `CityPostSchema` belum ada.

- [ ] **Step 3: Implementasi modul**

Buat `CityPostSchema` dengan konstanta di atas. `PLACEHOLDER_PATTERN` mencocokkan `{{...}}`, `{NAMA_KOTA}`, `{kota}`, `{KOTA}`. `placeholders` memeriksa field bertipe String secara rekursif pada Hash/Array dan mengembalikan nama field tingkat atas yang mengandung pola itu.

- [ ] **Step 4: Jalankan ulang test**

Run: `ruby test/test_city_post_schema.rb`
Expected: PASS (5 assertions, 0 failures).

- [ ] **Step 5: Commit**

```bash
git add scripts/lib/city_post_schema.rb test/test_city_post_schema.rb
git commit -m "feat: define canonical 39-field city post schema"
```

---

### Task 2: Default kanonik dan profil kota

**Files:**
- Create: `scripts/data/city-defaults.yml`
- Create: `scripts/data/city-post-body.md`
- Create: `scripts/data/city-profiles.yml`
- Create: `scripts/lib/city_profile.rb`
- Create: `test/test_city_profile.rb`

**Interfaces:**
- Consumes: `CityPostSchema::REQUIRED_FIELDS` dari Task 1.
- Produces: `CityProfile.load(path) -> Hash` dengan keys `defaults` dan `cities`; `CityProfile.load_defaults -> Hash` yang membaca `scripts/data/city-defaults.yml`; `CityProfile.validate_city!(city) -> true` (raise `ArgumentError` untuk field wajib hilang atau slug invalid); `CityProfile.merge(defaults, city) -> Hash`. `city-profiles.yml` berisi `defaults: {}` dan `cities: []` sebagai contoh kosong.

- [ ] **Step 1: Tulis test yang gagal**

Buat `test/test_city_profile.rb` dengan assertions:
- YAML `city-defaults.yml` memiliki keys persis sama dengan `CityPostSchema::REQUIRED_FIELDS.sort`.
- `city-post-body.md` mengandung `{{nama_kota}}` dan tidak mengandung string literal `Gowa`.
- `CityProfile.validate_city!({"slug"=>"bogor","nama_kota"=>"Bogor","tanggal"=>"2026-12-01","foto_source"=>"a.jpeg"})` mengembalikan `true`.
- `CityProfile.validate_city!` raise `ArgumentError` jika `foto_source` hilang.
- `CityProfile.validate_city!` raise `ArgumentError` untuk slug `"Bogor Utara"`.
- `CityProfile.merge(defaults, city)` mengganti token `{{nama_kota}}` di nested string dengan `city["nama_kota"]`, dan `overrides` menimpa nilai default pada nested Hash.

- [ ] **Step 2: Jalankan test untuk memastikan gagal**

Run: `ruby test/test_city_profile.rb`
Expected: FAIL karena file/data belum ada.

- [ ] **Step 3: Buat data default**

Salin isi frontmatter artikel `2026-06-28-jual-kayu-dolken-gowa.md` ke `scripts/data/city-defaults.yml`, lalu:
- samakan `images` menjadi tepat satu path ber-token `/assets/images/posts/jual-kayu-dolken-{{slug}}/jual-kayu-dolken-{{slug}}-001.webp`,
- samakan `images_alt` menjadi tepat satu string `{{nama_kota}}`,
- ganti semua sebutan "Gowa"/"gowa" dengan `{{nama_kota}}`/`{{slug}}`,
- set `date: "{{tanggal}}"`, `last_modified_at: "{{tanggal}}"`,
- hapus field apa pun yang tidak ada di `CityPostSchema::REQUIRED_FIELDS`.

Ambil `like_count` dari artikel Makassar karena Gowa tidak memilikinya. Hasil akhir harus tepat 39 keys dan bebas token selain `{{nama_kota}}`, `{{slug}}`, `{{tanggal}}`.

Buat pula `scripts/data/city-post-body.md` dari bagian setelah frontmatter artikel Gowa; ganti `nama_kota="Gowa"` menjadi `nama_kota="{{nama_kota}}"` dan biarkan semua `{% include %}` apa adanya.

- [ ] **Step 4: Implementasi `CityProfile`**

`load` memakai `YAML.safe_load(..., aliases: true)`; `merge` melakukan deep merge `defaults` dengan `city["overrides"]` lalu mengganti token secara rekursif pada string. Generator akan menentukan `image`, `images`, `image_alt`, dan `images_alt` sendiri, jadi `merge` tidak perlu mengubah keempat field itu lebih lanjut.

- [ ] **Step 5: Jalankan ulang test**

Run: `ruby test/test_city_profile.rb`
Expected: PASS (6 assertions, 0 failures).

- [ ] **Step 6: Commit**

```bash
git add scripts/data/city-defaults.yml scripts/data/city-post-body.md scripts/data/city-profiles.yml scripts/lib/city_profile.rb test/test_city_profile.rb
git commit -m "feat: add canonical city defaults and profile loader"
```

---

### Task 3: Generator artikel dan gambar

**Files:**
- Create: `scripts/generate-city-post.rb`
- Create: `test/test_generate_city_post.rb`

**Interfaces:**
- Consumes: `CityPostSchema` (Task 1), `CityProfile` (Task 2).
- Produces: `CityPostGenerator.image_sha256(path) -> String`, `CityPostGenerator.convert_to_webp(src, dest) -> void`, `CityPostGenerator.append_provenance(root:, entry:) -> void`, `CityPostGenerator.generate(city, root:, defaults: CityProfile.load_defaults, dry_run: false) -> String`. Error: `CityPostGenerator::SourceImageMissingError`, `CityPostGenerator::OutputExistsError`, `CityPostGenerator::DuplicateImageError`. `generate` mengembalikan path relatif artikel dan tidak menulis apa pun saat `dry_run: true`. Template body dibaca dari lokasi script (`File.expand_path("data/city-post-body.md", __dir__)`), bukan dari `root`, sehingga test dengan `root` sementara tetap memakai template asli.

- [ ] **Step 1: Tulis test sukses**

Buat `test/test_generate_city_post.rb`. Di `setup`, buat `Dir.mktmpdir` sebagai `root`, lalu buat fixture foto dengan:
`ffmpeg -hide_banner -loglevel error -f lavfi -i color=c=red:s=64x64 -frames:v 1 <root>/source-image/sample.jpeg`.
Profile uji: `slug: "bogor"`, `nama_kota: "Bogor"`, `tanggal: "2026-12-01"`, `foto_source: "sample.jpeg"`.
Assertions:
- `generate(..., root: root, dry_run: false)` mengembalikan `_post_with_city/2026-12-01-jual-kayu-dolken-bogor.md` dan file itu ada.
- Frontmatter Markdown memiliki ke-39 field dari `CityPostSchema::REQUIRED_FIELDS`.
- Bagian setelah frontmatter berisi `{% include reusable/post-with-city/block--hero-jual-kayu-dolken.html %}` dan `nama_kota="Bogor"`.
- Tidak ada token `{{` tersisa di file.
- `image` dan `images[0]` sama dengan `/assets/images/posts/jual-kayu-dolken-bogor/jual-kayu-dolken-bogor-001.webp`, file WebP itu ada, dan tidak ada file `.jpeg` di direktori output.
- `scripts/data/image-provenance.jsonl` memiliki satu baris dengan `sha256` foto fixture, `source: "source-image/sample.jpeg"`, dan `slug: "bogor"`.
- `generate(..., dry_run: true)` untuk kota `solo` tidak membuat file artikel maupun direktori gambar.

- [ ] **Step 2: Tulis test duplikat gambar**

Assertion: `generate` dengan `overrides` yang membuat `images` berisi dua path dengan hash sama harus raise `DuplicateImageError`, dan tidak ada artikel baru yang tertulis. (Gunakan dua path berbeda yang keduanya berisi byte fixture yang sama.)

- [ ] **Step 3: Tulis test foto sumber hilang / di luar source-image**

Assertion: `foto_source: "missing.jpeg"` raise `SourceImageMissingError`; `foto_source: "../luar.jpeg"` (file ada di luar `source-image/`) juga raise `SourceImageMissingError`. Keduanya tidak boleh meninggalkan direktori output.

- [ ] **Step 4: Tulis test penimpaan**

Assertion: memanggil `generate` dua kali dengan slug dan tanggal sama raise `OutputExistsError` pada pemanggilan kedua, dan isi artikel pertama tidak berubah.

- [ ] **Step 5: Jalankan test untuk memastikan gagal**

Run: `ruby test/test_generate_city_post.rb`
Expected: FAIL karena `CityPostGenerator` belum ada.

- [ ] **Step 6: Implementasi generator**

`generate` harus, sesuai urutan: validasi profil → pastikan `foto_source` berada di dalam `root/source-image/` dan ada → hitung SHA-256 → tolak bila artikel output sudah ada → cek keunikan hash semua gambar hasil `merge` → (jika bukan dry-run) salin foto, konversi WebP, hapus salinan `.jpeg`, tulis Markdown berupa `---` + frontmatter hasil `YAML.dump` + `---` + isi `scripts/data/city-post-body.md` yang sudah disubstitusi token, lalu tambahkan provenance. CLI menerima `--profile`, `--slug`, `--dry-run`; bila `defaults` di profil kosong, CLI memakai `CityProfile.load_defaults`. CLI keluar dengan status 1 disertai pesan bila raise.

- [ ] **Step 7: Jalankan ulang test**

Run: `ruby test/test_generate_city_post.rb`
Expected: PASS (4 test methods, 0 failures).

- [ ] **Step 8: Commit**

```bash
git add scripts/generate-city-post.rb test/test_generate_city_post.rb
git commit -m "feat: generate city posts with deduplicated WebP images"
```

---

### Task 4: Validator

**Files:**
- Create: `scripts/validate-city-post.rb`
- Create: `test/test_validate_city_post.rb`
- Modify: `validate-post.sh` (ganti seluruh isi menjadi wrapper tipis)

**Interfaces:**
- Consumes: `CityPostSchema` (Task 1), format provenance dari Task 3.
- Produces: `CityPostValidator::Result = Struct.new(:errors, :warnings, keyword_init: true)` dengan `success?` (true bila `errors.empty?`); `CityPostValidator.validate_file(path, root: Dir.pwd, strict: false) -> Result`. `validate-post.sh` menerima `<file>` dan flag `--new` (strict) serta meneruskan exit code 1 bila ada error.

- [ ] **Step 1: Tulis test mode default**

Buat `test/test_validate_city_post.rb`. Fixture: artikel valid hasil generator (39 field, 1 gambar WebP yang ada di fixture root, provenance berisi hash-nya) dan artikel lama yang sengaja dihapus 7 field-nya.
Assertions:
- artikel valid → `errors == []` dan `warnings == []`.
- artikel lama mode default → `errors == []` dan `warnings` menyebut field yang hilang.
- nama file tidak mengikuti pola `YYYY-MM-DD-jual-kayu-dolken-*.md` → `warnings` berisi peringatan nama file, `errors == []`.
- placeholder `{{nama_kota}}` di `title` → `errors` tidak kosong.
- path `image` tidak ada di filesystem → `errors` tidak kosong.
- dua entri `images` dengan hash sama → `errors` tidak kosong.

- [ ] **Step 2: Tulis test mode strict**

Assertions:
- mode `strict: true` pada artikel lama → `errors` tidak kosong (field hilang jadi error).
- mode `strict: true` pada artikel valid tanpa entri provenance cocok → `errors` tidak kosong.
- mode `strict: true` pada artikel dengan 2 entri `images` → `errors` tidak kosong.

- [ ] **Step 3: Jalankan test untuk memastikan gagal**

Run: `ruby test/test_validate_city_post.rb`
Expected: FAIL karena `CityPostValidator` belum ada.

- [ ] **Step 4: Implementasi validator**

Parsing frontmatter memakai `YAML.safe_load(..., permitted_classes: [Date, Time], aliases: true)`. Pemeriksaan: field hilang (error di strict / warning di default), placeholder (error), setiap path di `image`/`images` berakhir `.webp` dan file ada relatif terhadap `root`, `image == images.first`, hash unik, pola nama file, dan di strict: tepat satu `images` + satu `images_alt` serta hash ada di `scripts/data/image-provenance.jsonl` dengan source berada di dalam `source-image/`.

- [ ] **Step 5: Ganti `validate-post.sh`**

Isi wrapper: `exec ruby "$(dirname "$0")/scripts/validate-city-post.rb" "$@"`. Pertahankan executable bit.

- [ ] **Step 6: Jalankan ulang test**

Run: `ruby test/test_validate_city_post.rb`
Expected: PASS (2 test methods, 0 failures).

- [ ] **Step 7: Commit**

```bash
git add scripts/validate-city-post.rb test/test_validate_city_post.rb validate-post.sh
git commit -m "feat: rewrite post validator with strict mode and image checks"
```

---

### Task 5: Panduan, konfigurasi, dan verifikasi ujung-ke-ujung

**Files:**
- Create: `docs/CARA-TAMBAH-KOTA.md`
- Modify: `_config.yml` (tambah `- test/` ke daftar `exclude`)

**Interfaces:**
- Consumes: CLI generator dari Task 3 dan `validate-post.sh` dari Task 4.
- Produces: prosedur terdokumentasi untuk menambah kota dan build sukses tanpa artikel baru ikut terbit sebagai `test/`.

- [ ] **Step 1: Tulis panduan**

`docs/CARA-TAMBAH-KOTA.md` harus memuat, berurutan: (1) isi entri di `scripts/data/city-profiles.yml` dengan `slug`, `nama_kota`, `tanggal`, `foto_source` relatif terhadap `source-image/`, dan `overrides` opsional; (2) `ruby scripts/generate-city-post.rb --profile scripts/data/city-profiles.yml --dry-run`; (3) jalankan tanpa `--dry-run`; (4) `./validate-post.sh --new _post_with_city/<file>.md`; (5) `./rebuild.sh build`; (6) `git status` lalu commit. Sertakan catatan bahwa foto boleh reused lintas kota tetapi tidak boleh duplikat di satu artikel, dan semua foto wajib dari `source-image/`.

- [ ] **Step 2: Perbarui exclude**

Tambah `- test/` tepat setelah `- scripts/` pada blok `exclude` di `_config.yml`.

- [ ] **Step 3: Verifikasi ujung-ke-ujung**

Jalankan:
```bash
ruby scripts/generate-city-post.rb --profile scripts/data/city-profiles.yml --dry-run
./validate-post.sh _post_with_city/2026-06-28-jual-kayu-dolken-gowa.md
bundle exec jekyll build --destination /tmp/opencode/jekyll-check --future
grep -q 'test/' _config.yml
```
Expected: dry-run tidak mengubah file; validator menghasilkan warning, bukan error, untuk artikel Gowa; build selesai tanpa error; `_config.yml` memuat `test/`.

- [ ] **Step 4: Commit**

```bash
git add docs/CARA-TAMBAH-KOTA.md _config.yml
git commit -m "docs: document city post workflow and exclude tests from build"
```
