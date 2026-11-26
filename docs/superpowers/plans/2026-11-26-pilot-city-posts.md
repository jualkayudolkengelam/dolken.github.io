# Rencana: Pilot 3 artikel kota dengan default netral

Dari `docs/superpowers/specs/2026-11-26-pilot-city-posts-design.md`. Root repo `/www/wwwroot/jualkayudolken`, branch `main` (izin commit/push sudah diberikan pemilik).

## Task 1 — Test regresi netralisasi (RED)

**File baru:** `test/test_neutral_city_defaults.rb`

- `require "minitest/autorun"`, `require "yaml"`, `require_relative "../scripts/lib/city_profile"`, `require_relative "../scripts/lib/city_post_schema"`.
- `DEFAULTS = CityProfile.load_defaults` (dibaca sekali di konstanta).
- `FORBIDDEN = %w[Sungguminasa Malino Makassar Gowa Sulawesi Sulsel Somba\ Opu Pallangga Bajeng Bontonompo Tinggimoncong Biringbulu Balla\ Lompoa Katangka Pisang\ Epe Hasanuddin]` — gunakan array string utuh, bukan token pecah.
- Test `test_defaults_have_no_legacy_city_facts`: `serialized = YAML.dump(DEFAULTS)`; `refute_match` untuk setiap entri `FORBIDDEN`; `refute_match(/在哪里|sakbis/)`; `refute_match(/18 kecamatan|1\.883 km|765\.000|167 kelurahan|13 kecamatan/)`.
- Test `test_defaults_have_no_template_instructions`: untuk tiap nilai `finalisasi_pengiriman`, `refute_match(/\A(tulis|jelaskan|mention)\b/i, value.to_s)`.
- Test `test_substituted_defaults_have_no_placeholders`: `merged = CityProfile.merge(DEFAULTS, {"slug" => "tangerang", "nama_kota" => "Tangerang", "tanggal" => "2026-11-26", "foto_source" => "x.jpeg"})`; `assert_empty CityPostSchema.placeholders(merged)`.
- Jalankan `ruby test/test_neutral_city_defaults.rb` → **harus gagal** karena masih ada nama Gowa dan teks instruksi. Commit: `test: add regression for neutral city defaults`.

## Task 2 — Netralisasi `city-defaults.yml` (GREEN)

**File:** `scripts/data/city-defaults.yml` (tulis ulang seluruhnya dengan `write`).

- Pertahankan 39 field kanonik dan bentuk nested yang dipakai include:
  - `area_pengiriman` array string zona umum;
  - `area_pengiriman_detail` memuat semua kunci yang dibaca include (`judul_*`, `deskripsi_*`, `wilayah_pusat`, `wilayah_utara_selatan`, `wilayah_pengembangan`, `landmark_wisata`, `landmark_fasilitas`, `kecamatan_lainnya` opsional — sertakan 4 zona umum);
  - `tentang_kota` memuat `tagline`, `deskripsi_singkat`, `overview`, `tentang_kota_1`, `tentang_kota_2` dengan struktur kartu yang sama (judul/icon/subjudul/icon_subjudul/deskripsi/fakta atau list_item);
  - `studi_kasus_proyek` memuat `proyek_komersial`, `proyek_residensial`, `proyek_publik`;
  - `testimoni_residential`, `testimoni_komersial`, `tips_ukuran`, `faq_*`, `relevansi_kayu_dolken`, `keunggulan_*`, `aplikasi_kayu_dolken`, `proses_awal_pemesanan`, `finalisasi_pengiriman`.
- Ganti semua nama tempat/angka demografi dengan narasi generik berbasis `{{nama_kota}}`; jangan menambah klaim lokasi baru.
- `finalisasi_pengiriman` ditulis sebagai kalimat customer-facing, bukan instruksi template.
- Token yang boleh tetap: `{{nama_kota}}`, `{{slug}}`, `{{tanggal}}` (dibaca `CityProfile::TOKEN_KEYS`).
- Jalankan `ruby test/test_neutral_city_defaults.rb` → hijau. Commit: `fix: neutralize city defaults for reusable city posts`.

## Task 3 — Profil pilot (RED → GREEN)

**Test baru:** `test/test_pilot_city_profiles.rb`

- Muat `CityProfile.load("scripts/data/city-profiles.yml")`.
- Test `test_pilot_cities_are_complete_and_distinct`: `slugs == %w[tangerang surabaya denpasar]`; tiap kota `nama_kota` sesuai (`Tangerang`, `Surabaya`, `Denpasar`), `tanggal == "2026-11-26"`, `CityProfile.validate_city!(city)` lolos; 3 `foto_source` berbeda dan `sha256` berbeda; file sumber ada di bawah `source-image/`.
- Jalankan → RED (`cities: []`). Isi `scripts/data/city-profiles.yml` dengan:
  - `tangerang` → `WhatsApp Unknown 2026-11-26 at 13.33.35/WhatsApp Image 2026-10-05 at 17.37.22.jpeg` (sha `8649cccc1f0b…`)
  - `surabaya` → `WhatsApp Unknown 2026-11-26 at 13.33.49/WhatsApp Image 2026-10-17 at 17.09.45.jpeg` (sha `6324b69ff283…`)
  - `denpasar` → `WhatsApp Unknown 2026-11-26 at 13.34.06/WhatsApp Image 2026-11-14 at 12.52.27.jpeg` (sha `ff88cf155638…`)
- Jalankan → GREEN. Commit: `feat: add pilot city profiles for Tangerang Surabaya Denpasar`.

## Task 4 — Generate 3 artikel (RED → GREEN)

**Test baru:** `test/test_pilot_city_posts.rb`

- Test `test_generated_pilot_articles_exist`: untuk 3 slug, path `_post_with_city/2026-11-26-jual-kayu-dolken-<slug>.md` ada.
- Test `test_generated_pilot_articles_pass_strict_validation`: `CityPostValidator.validate_file(path, root: Dir.pwd, strict: true)` → `errors` dan `warnings` kosong.
- Test `test_provenance_matches_generated_images`: baca `scripts/data/image-provenance.jsonl`, untuk tiap slug ada entri dengan `source` diawali `source-image/`, `output` sesuai path WebP, `output_sha256 == Digest::SHA256.file(...)`.
- RED dulu. Lalu:
  - `ruby scripts/generate-city-post.rb --dry-run` → 3 path tercetak, tanpa file baru;
  - `ruby scripts/generate-city-post.rb` → 3 artikel + 3 WebP + provenance;
  - jalankan test → GREEN.
- Commit: `post: add pilot city articles for Tangerang Surabaya Denpasar`.

## Task 5 — Verifikasi & integrasi

- `ruby test/test_existing_city_posts.rb` dan seluruh `for f in test/test_*.rb; do ruby "$f"; done` → hijau.
- `./validate-post.sh --new` pada 3 artikel baru → 0 error; `./validate-post.sh` pada 6 artikel lama → tetap 0 warning.
- `grep -E 'Sungguminasa|Malino|Makassar|Gowa|Sulawesi|Sulsel|在哪里|sakbis|\{\{|\{NAMA_KOTA\}'` pada 3 artikel baru → tidak ada.
- Jekyll build dengan `GEM_HOME=/home/aapanel/.local/share/gem/ruby/3.3.0/ruby/3.3.0 GEM_PATH="$GEM_HOME:/var/lib/gems/3.3.0" PATH="$GEM_HOME/bin:$PATH" bundle exec jekyll build --future --destination /tmp/opencode/jekyll-pilot-city` → exit 0 (`bundle` tidak ada di PATH default shell).
- `git status --short`: `source-image/` tidak muncul; commit per task sudah ada.
- Push `main` ke origin dengan PAT dari `~/.git-pat-kayu-dolken`, helper kredensial sementara, output diredaksi.
- Review akhir satu putaran; Critical/Important diperbaiki RED→GREEN, Minor dicatat.

## Catatan

- Foto boleh dipakai ulang lintas kota, tapi hash duplikat dalam satu artikel dilarang; 3 foto pilot sudah dipilih berbeda hash.
- Jangan mengubah 6 artikel existing, include, layout, atau skema 39 field.
- `source-image/` tetap gitignored.
