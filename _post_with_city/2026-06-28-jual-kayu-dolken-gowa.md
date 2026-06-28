---
# ============================================================================
# TEMPLATE: POST WITH CITY (Format Instruksi)
# ============================================================================
# File: TEMPLATE--post-with-city.md
# Purpose: Template untuk membuat artikel post_with_city dengan konten UNIQUE
# Version: 2.0.0 (Instruction Format)
# Date: 2025-11-19
#
# CARA PENGGUNAAN:
# 1. Copy file ini ke _post_with_city/ dengan nama: YYYY-MM-DD-jual-kayu-dolken-{kota}.md
# 2. Siapkan 4 foto produk (PENTING: harus format WebP):
#    a. Buat direktori:
#       mkdir -p assets/images/posts/jual-kayu-dolken-{kota}/
#    b. Copy 1,2,3,atau 4 foto sesuai yang diberikan ke direktori dan rename:
#       cp foto1.jpg assets/images/posts/jual-kayu-dolken-{kota}/jual-kayu-dolken-{kota}-001.jpeg
#       cp foto2.jpg assets/images/posts/jual-kayu-dolken-{kota}/jual-kayu-dolken-{kota}-002.jpeg
#       (dst untuk 003 dan 004)
#    c. Convert semua JPEG ke WebP (akan menghasilkan file .webp baru):
#       cd assets/images/posts/jual-kayu-dolken-{kota}/
#       for file in *.jpeg; do cwebp -q 85 "$file" -o "${file%.jpeg}.webp"; done
#    d. Hapus file JPEG yang lama (sekarang ada 2x file: .jpeg dan .webp):
#       rm *.jpeg
#    e. Pastikan hanya ada 4 file .webp: 001.webp, 002.webp, 003.webp, 004.webp
# 3. Baca INSTRUKSI di setiap field (yang ditulis dengan huruf kecil)
# 4. Ganti instruksi dengan konten yang sesuai untuk kota tersebut
# 5. Field yang sudah ada teksnya (UPPERCASE) bisa dipakai langsung atau disesuaikan
# 6. Test dengan rebuild.sh sebelum commit
#
# CATATAN PENTING:
# - Field dengan "isi ..." atau "tulis ..." atau "berikan ..." = HARUS DITULIS MANUAL
# - Field dengan teks lengkap (misal: "Kualitas Premium Grade A") = boleh pakai langsung
# - Jangan ubah struktur frontmatter (nama field, hierarki, indentasi)
# - Semua section dengan REQUIRED wajib diisi
# - Section OPTIONAL boleh dihapus jika tidak relevan
# - PENTING: Semua foto HARUS dalam format WebP (bukan JPEG/PNG) untuk optimasi performa
# ============================================================================

# ============================================================================
# SECTION META INFORMATION (REQUIRED)
# ============================================================================
layout: node--post-with-city
title: "Jual Kayu Dolken di Gowa – Hubungi 0813-1140-0177, Gratis Ongkir ke Seluruh Gowa!"
description: "Jual Kayu Dolken Gowa – kualitas premium, tahan lama, harga mulai Rp15.000. Gratis ongkir ke seluruh Gowa! Hubungi 0813-1140-0177 untuk pemesanan."
excerpt: "Jual kayu dolken premium di Gowa – gratis ongkir, harga terbaik, barang berkualitas."
date: 2026-06-28
author: Admin
image: /assets/images/posts/jual-kayu-dolken-gowa/jual-kayu-dolken-gowa-001.webp
image_alt: "Jual Kayu Dolken Gowa — kualitas premium"
images:
  - /assets/images/posts/jual-kayu-dolken-gowa/jual-kayu-dolken-gowa-001.webp
  - /assets/images/posts/jual-kayu-dolken-gowa/jual-kayu-dolken-gowa-002.webp
  
  
images_alt:
  - "Jual Kayu Dolken Gowa — kualitas premium kayu dolken"
  - "Jual Kayu Dolken Gowa — gratis ongkir ke seluruh Gowa"
  - "Jual Kayu Dolken Gowa — stok lengkap diameter 2-12 cm"
  - "Jual Kayu Dolken Gowa — harga mulai Rp15.000 per batang"
last_modified_at: 2026-06-28
keywords: "kayu dolken gowa, jual kayu gowa, kayu beton gowa, kayu tahan cuaca gowa, kayu murah gowa, kayu bekisting gowa, dolken gowa, kayu bulat gowa"
rating: 5
review_count: 8
author_url: https://jualkayudolken.com
show_products: true
nama_kota: "Gowa"

# ============================================================================
# SECTION AREA PENGIRIMAN (SIMPLE LIST) - REQUIRED
# ============================================================================
# Instruksi: Isi 5-10 area/kecamatan populer di kota ini
area_pengiriman:
- "Somba Opu"
- "Pallangga"
- "Barombong"
- "Bajeng"
- "Bontonompo"
- "Tinggimoncong"
- "Bontomarannu"
- "Parigi"
- "Pattallassang"
- "Biringbulu"
keunggulan_produk:
  - judul: "Kualitas Premium, Tahan Cuaca Ekstrem"
    deskripsi: "Kayu Dolken tahan lama hingga 30 tahun, cocok untuk iklim tropis Gowa — dari dataran rendah Sungguminasa hingga pegunungan Malino."
    warna: "warning"
    icon: "bi-award-fill"
  - judul: "Harga Terjangkau Mulai Rp15.000"
    deskripsi: "Mulai Rp15.000 per batang, harga terbaik di Gowa untuk kualitas setara kayu keras."
    warna: "danger"
    icon: "bi-cash-coin"
  - judul: "Stok Lengkap & Selalu Ready"
    deskripsi: "Diameter 2-12 cm tersedia, stok melimpah siap kirim ke seluruh Gowa."
    warna: "info"
    icon: "bi-boxes"

# ============================================================================
# SECTION KEUNGGULAN - LAYANAN (REQUIRED)
# ============================================================================
keunggulan_layanan:
  - judul: "Gratis Ongkir ke Seluruh Gowa"
    deskripsi: "Nikmati pengiriman gratis ke 13 kecamatan di Gowa — dari Sungguminasa hingga Malino. Minimal order 50 batang."
    warna: "success"
    icon: "bi-truck"
  - judul: "COD Tersedia, Bayar Setelah Terima"
    deskripsi: "Sistem COD aman — cek kualitas kayu Dolken sebelum bayar. Berlaku untuk wilayah Gowa dan Makassar."
    warna: "primary"
    icon: "bi-shield-check"
  - judul: "Konsultasi Gratis & Fast Response"
    deskripsi: "Tim kami siap konsultasi via WA, bantu pilih ukuran dan jumlah kayu Dolken yang tepat untuk proyek Anda."
    warna: "secondary"
    icon: "bi-headset"

# ============================================================================
# SECTION AREA PENGIRIMAN DETAIL - TEKS JUDUL & DESKRIPSI (REQUIRED)
# ============================================================================
area_pengiriman_detail:
  judul_jangkauan: "Jangkauan Pengiriman ke Seluruh Gowa"
  deskripsi_jangkauan: "Kami melayani pengiriman gratis ke 13+ kecamatan di Gowa — dari Sungguminasa hingga Malino. Gratis ongkir!"

  judul_pusat: "Wilayah Pusat Gowa — Sungguminasa & Sekitarnya"
  deskripsi_pusat: "Pusat Gowa meliputi Somba Opu (Sungguminasa), Pallangga, dan Barombong — kawasan bisnis, pemerintahan, dan pusat perbelanjaan dengan akses mudah dari Makassar."

  judul_utara_selatan: "Wilayah Utara & Selatan Gowa"
  deskripsi_utara_selatan: "Bagian utara Gowa (Bajeng, Bontonompo) dekat Makassar dan berkembang pesat. Bagian selatan (Biringbulu, Bungaya) tumbuh sebagai kawasan hunian dan agrowisata."

  judul_pengembangan: "Wilayah Pengembangan Gowa — Potensi Wisata & Agrowisata"
  deskripsi_pengembangan: "Wilayah seperti Tinggimoncong (Malino), Parigi, dan Tompobulu dikenal sebagai destinasi wisata pegunungan dan agrowisata. Proyek perumahan dan villa terus berkembang."

  judul_lainnya: "Kecamatan Lainnya di Gowa"

  judul_landmark: "Landmark & Lokasi Strategis di Gowa"
  deskripsi_landmark: "Landmark seperti Balla Lompoa, Alun-Alun Sungguminasa, dan Pasar Sentral Gowa mendorong aktivitas bisnis dan proyek konstruksi."

  judul_wisata: "Destinasi Wisata di Gowa"
  deskripsi_wisata: "Gowa memiliki wisata alam pegunungan seperti Malino Highlands, Air Terjun Malino, dan Pemandian Air Panas Leija yang menjadi favorit wisatawan."

  judul_fasilitas: "Fasilitas Pendidikan & Komersial di Gowa"
  deskripsi_fasilitas: "Kampus UMI, Gowa Town Center (GTC), RSUD Syekh Yusuf, dan Bandara Sultan Hasanuddin (area Gowa) menjadikan Gowa kota strategis."

# ============================================================================
# SECTION AREA PENGIRIMAN DETAIL - WILAYAH PUSAT (REQUIRED - min 3 items)
# ============================================================================
# Instruksi: Research kecamatan NYATA di pusat kota ini, cari kelurahan yang ada
  wilayah_pusat:
    - nama: "Somba Opu"
      kelurahan:
        - "Sungguminasa, Samata, Tombolo, Bontoramba"
      warna: "primary"
    - nama: "Pallangga"
      kelurahan:
        - "Mangalli, Pangkabinanga, Taeng, Jene'tallasa"
      warna: "success"
    - nama: "Barombong"
      kelurahan:
        - "Moncobalang, Lembang, Pacarring, Tinggimae"
      warna: "info"
    # Tambah lebih banyak jika perlu (5-7 kecamatan ideal)

# ============================================================================
# SECTION AREA PENGIRIMAN DETAIL - WILAYAH UTARA & SELATAN (OPTIONAL)
# ============================================================================
# Instruksi: Hapus section ini jika kota tidak punya pembagian utara-selatan yang jelas
  wilayah_utara_selatan:
    - nama: "Bajeng"
      kelurahan:
        - "Bontomationgi, Limbung, Kalebajeng, Mata Allo"
      warna: "danger"
    - nama: "Bontonompo"
      kelurahan:
        - "Bontonompo, Kalapalaga, Kalaserena"
      warna: "warning"

# ============================================================================
# SECTION AREA PENGIRIMAN DETAIL - WILAYAH PENGEMBANGAN (REQUIRED - min 2 items)
# ============================================================================
# Instruksi: Isi kecamatan yang sedang berkembang/pinggiran kota
  wilayah_pengembangan:
    - nama: "Tinggimoncong"
      kelurahan:
        - "Malino, Bontolerung, Gantarang"
      warna: "primary"
    - nama: "Parigi"
      kelurahan:
        - "Parigi, Manuju, Bilalang"
      warna: "info"
    - nama: "Tompobulu"
      kelurahan:
        - "Tompobulu, Tanete, Bongo Ramba"
      warna: "wood"

# ============================================================================
# SECTION AREA PENGIRIMAN DETAIL - LANDMARK WISATA (REQUIRED - min 3 items)
# ============================================================================
# Instruksi: Isi landmark WISATA dan sejarah yang terkenal di kota ini
  landmark_wisata:
    - nama: "Balla Lompoa Museum"
      icon: "bi-building"
      warna: "warning"
    - nama: "Air Terjun Malino"
      icon: "bi-building"
      warna: "warning"
    - nama: "Pemandian Air Panas Leija"
      icon: "bi-building"
      warna: "warning"
    - nama: "Puncak Bila-Bila"
      icon: "bi-building"
      warna: "warning"

# ============================================================================
# SECTION AREA PENGIRIMAN DETAIL - LANDMARK FASILITAS (REQUIRED - min 3 items)
# ============================================================================
# Instruksi: Isi fasilitas strategis seperti mall, kampus, pelabuhan di kota ini
  landmark_fasilitas:
    - nama: "Gowa Town Center (GTC)"
      icon: "bi-cart"
      warna: "info"
    - nama: "Pasar Sentral Sungguminasa"
      icon: "bi-cart"
      warna: "primary"
    - nama: "Universitas Muslim Indonesia (UMI)"
      icon: "bi-mortarboard"
      warna: "success"

# ============================================================================
# SECTION KEUNGGULAN PRODUK - DURABILITAS (OPTIONAL)
# ============================================================================
keunggulan_durabilitas:
  tahan_lama: "Kayu Dolken Gowa tahan 20-30 tahun tanpa treatment, cocok untuk iklim tropis lembab Gowa — dari pesisir Sungguminasa hingga pegunungan Malino."
  anti_rayap: "Tekstur padat kayu gelam alami menolak rayap tanpa obat kimia, ideal untuk rumah di wilayah lahan gambut Gowa."
  tahan_cuaca: "Tahan hujan deras musim penghujan Gowa dan panas terik musim kemarau — cocok indoor & outdoor."
  kuat_padat: "Kepadatan tinggi (0.8-1.0 g/cm³), kekuatan tekan >50 MPa — kuat untuk struktur penyangga atap & lantai."

keunggulan_nilai:
  ramah_lingkungan: "Material natural 100% sustainable, biodegradable, mendukung sertifikasi green building proyek di Gowa."
  estetika: "Warna coklat merah natural khas kayu Dolken, semakin cantik seiring waktu — cocok desain rumah modern & tradisional Gowa."

# Format Array (lebih baru, direkomendasikan) - HARUS 6 items
keunggulan_kayu_dolken:
  - judul: "Tahan Lama 20-30 Tanah Tanpa Treatment"
    deskripsi: "Kayu Dolken Gowa tahan hingga 30 tahun tanpa treatment kimia, cocok untuk iklim tropis lembab dari pesisir hingga pegunungan."
    warna: "success"
    icon: "bi-clock-history"
  - judul: "Anti Rayap Alami Tanpa Obat"
    deskripsi: "Tekstur padat dan minyak alami kayu gelam menolak rayap natural — ideal untuk rumah di lahan gambut & dataran rendah Gowa."
    warna: "danger"
    icon: "bi-bug"
  - judul: "Tahan Cuaca Ekstrem: Hujan & Panas"
    deskripsi: "Tahan hujan deras musim penghujan & panas terik musim kemarau Gowa — cocok aplikasi indoor maupun outdoor."
    warna: "primary"
    icon: "bi-cloud-rain"
  - judul: "Kuat & Padat untuk Beban Berat"
    deskripsi: "Kepadatan 0.8-1.0 g/cm³, kekuatan tekan >50 MPa — kuat untuk struktur penyangga atap, lantai, dan kolom."
    warna: "warning"
    icon: "bi-hammer"
  - judul: "Ramah Lingkungan & Sustainable"
    deskripsi: "Material natural 100% biodegradable, mendukung green building — pilihan proyek eco-friendly di Gowa."
    warna: "success"
    icon: "bi-recycle"
  - judul: "Estetika Natural Coklat Merah Muda"
    deskripsi: "Warna coklat merah khas Dolken semakin cantik seiring waktu, cocok desain rumah modern & tradisional Gowa."
    warna: "info"
    icon: "bi-palette"

# ============================================================================
# SECTION APLIKASI KAYU DOLKEN (OPTIONAL - tapi direkomendasikan)
# ============================================================================
aplikasi_kayu_dolken:
  deskripsi: "Kayu Dolken serbaguna — dari konstruksi berat hingga dekorasi premium, cocok untuk proyek di Gowa."

  konstruksi_dekorasi:
    - judul: "Konstruksi & Bangunan"
      icon: "bi-building"
      warna: "wood"
      aplikasi:
        - "Struktur atap rumah & villa di Malino & Biringbulu"
        - "Kolom & balok kayu utama perumahan Sungguminasa"
        - "Lantai kayu tahan beban untuk rumah 2 lantai"
        - "Pagar & gate kayu solid area perumahan Gowa"
        - "Rangka carport & gazebo taman rumah mewah"
    - judul: "Dekorasi & Landscaping"
      icon: "bi-palette-fill"
      warna: "primary"
      aplikasi:
        - "Dinding aksen kayu ruang tamu & kamar tidur"
        - "Dek kayu outdoor taman & kolam renang"
        - "Pergola & gazebo kayu taman villa Malino"
        - "Furniture taman: meja, kursi, bali-bali kayu"
        - "Pagar dekoratif & trellis tanaman merambat"

  furniture_komersial:
    - judul: "Furniture & Lainnya"
      icon: "bi-chair-fill"
      warna: "info"
      aplikasi:
        - "Meja & kursi makan kayu solid premium"
        - "Bed frame & headboard kayu Dolken natural"
        - "Rak buku & wardrobe built-in custom"
        - "Bar counter & meja cafe kayu berat"
        - "Aksesoris kayu: lampu, frame, ornamen"
    - judul: "Proyek Komersial Terpercaya"
      icon: "bi-briefcase-fill"
      warna: "success"
      deskripsi: "Kami dipercaya developer & pengusaha Gowa untuk proyek komersial skala besar."
      aplikasi:
        - "Hotel & resort pegunungan Malino"
        - "Cafe & resto area Sungguminasa & GTC"
        - "Restoran pesisir Biringbulu & Pallangga"
        - "Mall & apartment"
        - "Developer perumahan"
        - "Developer perumahan"

# ============================================================================
# SECTION PROSES PEMESANAN - TAHAP AWAL (REQUIRED) - BOLEH PAKAI LANGSUNG
# ============================================================================
# Instruksi: Ini generic, boleh pakai langsung
proses_awal_pemesanan:
  pilih_ukuran: "Lihat daftar produk lengkap di atas, pilih diameter sesuai kebutuhan proyek Anda"
  hubungi: "081311400177"
  konsultasi_gratis: "Tim kami akan bantu hitung kebutuhan dan berikan rekomendasi terbaik untuk proyek Anda"

# ============================================================================
# SECTION PROSES PEMESANAN - FINALISASI & PENGIRIMAN (REQUIRED)
# ============================================================================
# Instruksi: Sesuaikan dengan nama kota
finalisasi_pengiriman:
  konfirmasi_pesanan: "tulis konfirmasi pesanan, mention pastikan jumlah/ukuran/alamat di Gowa sudah benar"
  pengiriman_gratis: "jelaskan pengiriman gratis, armada terpercaya, mention ke area kota ini, tepat waktu"
  bayar_cod: "jelaskan sistem COD, bayar setelah barang sampai dan dicek kualitas, aman tanpa risiko"

# ============================================================================
# SECTION STUDI KASUS PROYEK - KOMERSIAL (REQUIRED - min 4 items)
# ============================================================================
# Instruksi: HARUS custom per kota! Gunakan lokasi SPESIFIK yang ada di kota ini
studi_kasus_proyek:
  proyek_komersial:
    - judul: "Gazebo Restoran di Malino"
      tahun: "2024"
      deskripsi: "Restoran wisata di kawasan Malino, Tinggimoncong, Gowa renovasi gazebo outdoor pakai Kayu Dolken untuk tampilan alami dan tahan cuaca pegunungan."
      jumlah: "200 batang"
      diameter: "8-10 cm"
      hasil: "Gazebo kokoh dan tahan hujan deras khas Malino. Pengunjung puas."
      warna: "primary"
      icon: "bi-building"
    - judul: "Pagar Cafe di Sungguminasa"
      tahun: "2024"
      deskripsi: "Cafe baru di pusat kota Sungguminasa pakai Kayu Dolken untuk pagar dan dekorasi halaman."
      jumlah: "120 batang"
      diameter: "6-8 cm"
      hasil: "Tampilan halaman cafe rustic, outdoor tetap awet meski hujan."
      warna: "warning"
      icon: "bi-tree"
    - judul: "Rangka Atap Warung di Pallangga"
      tahun: "2024"
      deskripsi: "Warung makan di Pallangga pakai Kayu Dolken sebagai rangka atap semi-outdoor."
      jumlah: "150 batang"
      diameter: "8-10 cm"
      hasil: "Atap kokoh, tahan panas dan hujan."
      warna: "success"
      icon: "bi-shop"
    - judul: "Tiang Penyangga Toko di Bajeng"
      tahun: "2024"
      deskripsi: "Toko bangunan di Bajeng pakai Kayu Dolken untuk tiang penyangga area parkir."
      jumlah: "100 batang"
      diameter: "8 cm"
      hasil: "Tiang penyangga kokoh, tahan lembap dan rayap."
      warna: "danger"
      icon: "bi-building-add"

# ============================================================================
# SECTION STUDI KASUS PROYEK - RESIDENSIAL (REQUIRED - min 4 items)
# ============================================================================
  proyek_residensial:
    - judul: "Pagar Villa Kayu Dolken Malino"
      lokasi: "Desa Malino, Kec. Tinggimoncong, Gowa"
      tahun: "2024"
      deskripsi: "Pagar solid kayu Dolken diameter 8-10 cm untuk villa pegunungan Malino — tahan cuaca dingin & hujan deras."
      jumlah: "480"
      diameter: "8-10"
      hasil: "Klien puas — pagar kokoh 2 tahun tanpa kerusakan, anti rayap alami."
      warna: "success"
      icon: "bi-house-door"
    - judul: "Struktur Atap Rumah 2 Lantai Sungguminasa"
      lokasi: "Kel. Sungguminasa, Kec. Somba Opu, Gowa"
      tahun: "2024"
      deskripsi: "Kolom & rangka atap kayu Dolken diameter 6-12 cm untuk rumah mewah 2 lantai — struktur utama tanpa besi."
      jumlah: "650"
      diameter: "6-12"
      hasil: "Struktur kokoh, hemat biaya 30% vs baja, suhu ruang lebih sejuk."
      warna: "success"
      icon: "bi-sun"
    - judul: "Dek Kayu Outdoor Kolam Renang Biringbulu"
      lokasi: "Kec. Biringbulu, Gowa"
      tahun: "2024"
      deskripsi: "Dek kayu Dolken diameter 4-6 cm area kolam renang — anti licin & tahan air laut."
      jumlah: "320"
      diameter: "4-6"
      hasil: "Tahan air laut & panas 18 bulan, tidak melengkung."
      warna: "info"
      icon: "bi-tree-fill"
    - judul: "Pagar & Gate Perumahan Pallangga"
      lokasi: "Kel. Pallangga, Kec. Pallangga, Gowa"
      tahun: "2024"
      deskripsi: "Pagar & gerbang kayu Dolken diameter 8-10 cm untuk cluster perumahan — estetika natural."
      jumlah: "410"
      diameter: "8-10"
      hasil: "Zero keluhan rayap, developer pesan ulang untuk cluster baru."
      warna: "success"
      icon: "bi-house-heart-fill"

# ============================================================================
# SECTION STUDI KASUS PROYEK - PUBLIK (OPTIONAL - min 2 items)
# ============================================================================
  proyek_publik:
    - judul: "Gazebo & Jogging Track Taman Alun-Alun Sungguminasa"
      tahun: "2023"
      deskripsi: "Gazebo kayu Dolken dan decking area jogging track di Taman Alun-Alun Sungguminasa — pusat keramaian warga Gowa."
      jumlah: "250"
      diameter: "6-8"
      hasil: "Fasilitas publik kokoh, tahan cuaca — jadi spot favorit warga untuk bersantai & olahraga setiap sore."
      warna: "info"
      icon: "bi-signpost-2"
    - judul: "Mushola & Taman Belakang Islamic Center Gowa"
      tahun: "2024"
      deskripsi: "Pagar kayu Dolken dan decking taman area mushola Islamic Center Gowa — kawasan pusat keagamaan & edukasi."
      jumlah: "180"
      diameter: "6-8"
      hasil: "Area ibadah & taman nyaman, estetika natural cocok dengan arsitektur Islam modern. Diapresiasi pengurus masjid."
      warna: "success"
      icon: "bi-building"

# ============================================================================
# SECTION TESTIMONI - RESIDENTIAL (REQUIRED - min 2 items)
# ============================================================================
testimoni_residential:
  - nama: "Pak Andi"
    lokasi: "Somba Opu, Gowa"
    rating: 5
    judul: "Kualitas Terjamin"
    komentar: "Pesan kayu Dolken untuk pagar rumah di Somba Opu. Sudah 1.5 tahun tahan cuaca, tidak ada retakan. Pelayanan ramah, pengiriman tepat waktu."
    warna: "primary"
  - nama: "Ibu Nurul"
    lokasi: "Bontonompo, Gowa"
    rating: 5
    judul: "Anti Rayap Alami"
    komentar: "Tadinya ragu pakai kayu gelam, ternyata kokoh sekali. Pagar rumah saya di Bontonompo sudah 2 tahun aman dari rayap. Sangat puas."
    warna: "success"
  - nama: "Pak Hidayat"
    lokasi: "Pallangga, Gowa"
    rating: 5
    judul: "Pengiriman Cepat"
    komentar: "Renovasi rumah butuh kayu cepat. Pesanan saya 400 batang dia 8-10 sampai dalam 3 hari. Kualitas sesuai foto, harga bersaing."
    warna: "info"
  - nama: "Ibu Rahmawati"
    lokasi: "Malino, Gowa"
    rating: 5
    judul: "Cocok Untuk Villa"
    komentar: "Bangun villa di pegunungan Malino, pakai kayu Dolken untuk gazebo & dek. Tahan hujan & angin kencang. Tamu-tamu suka desainnya."
    warna: "success"

# ============================================================================
# SECTION TESTIMONI - KOMERSIAL (REQUIRED - min 4 items)
# ============================================================================
testimoni_komersial:
  - nama: "Pakarman"
    lokasi: "Owner Cafe Omah Kayu, GTC Sungguminasa"
    rating: 5
    judul: "Furniture Custom Sempurna"
    komentar: "Pesan bar counter & meja cafe kayu Dolken. Hasilnya premium, tamu sering tanya在哪里买的. Worth the investment."
    warna: "warning"
  - nama: "H. Idris"
    lokasi: "Pengembang perumahan Green Hill Residence, Pallangga"
    rating: 5
    judul: "Supplier Terpercaya"
    komentar: "Sudah 3 proyek perumahan pakai Dolken untuk pagar & gate. Konsisten quality, harga OKE, pengiriman on schedule."
    warna: "info"
  - nama: "Dra. St. Aminah"
    lokasi: "Pemilik Homestay Malino, Tinggimoncong"
    rating: 5
    judul: "Estetika Natural Unik"
    komentar: "Homestay di Malino pakai Dolken untuk gazebo & dek. Tamu asing suka banget. Kayunya makin cantik seiring waktu."
    warna: "success"
  - nama: "Bapak Firmansyah"
    lokasi: "Kontraktor, Somba Opu"
    rating: 5
    judul: "Rangka Atap Kokoh Murah"
    komentar: "Proyek rumah 2-3 lantai di Gowa pakai Dolken untuk rangka atap. Lebih hemat 25% dari baja, struktur equally strong."
    warna: "primary"

# ============================================================================
# SECTION TIPS MEMILIH UKURAN (REQUIRED) - BOLEH PAKAI LANGSUNG
# ============================================================================
# Produk yang tersedia 2-3 cm, 4-6 cm, 6-8 cm, 8-10 cm, 10-12 cm.
# jangan buat diameter diluar itu
tips_ukuran:
  - kategori: "Dekorasi Ringan"
    aplikasi: "Pagar, Taman"
    diameter: "2-3 cm / 4-6 cm"
    keunggulan:
      - "Cocok untuk estetika pagar & taman minimalis"
      - "Ringan, mudah dipasang, hemat biaya"
      - "Tersedia banyak variasi ukuran"
    warna: "success"
    icon: "bi-tree"
  - kategori: "Struktur Sedang"
    aplikasi: "Gazebo, Pergola"
    diameter: "6-8 cm"
    keunggulan:
      - "Kuat menahan beban atap & tanaman rambat"
      - "Diameter ideal untuk gazebo dan teras"
      - "Proporsi pas — kokoh tapi tidak terlalu besar"
    warna: "primary"
    icon: "bi-house-fill"
  - kategori: "Struktur Berat"
    aplikasi: "Tiang Utama, Pondasi"
    diameter: "8-10 cm / 10-12 cm"
    keunggulan:
      - "Kekuatan maksimal untuk kolom & balok utama"
      - "Mampu menahan beban konstruksi besar"
      - "Daya tahan 20-30 tahun tanpa treatment"
    warna: "danger"
    icon: "bi-building-fill"

# ============================================================================
# SECTION FAQ - PEMESANAN (REQUIRED - min 2 items)
# ============================================================================
# ============================================================================
faq_pemesanan:
  - pertanyaan: "Berapa minimal pemesanan kayu dolken?"
    jawaban: "Minimal pemesanan 10 batang. Untuk area Gowa tersedia harga khusus — hubungi 081311400177 untuk konsultasi gratis ukuran & kebutuhan."
    icon: "bi-cart-check"
  - pertanyaan: "Bagaimana cara mengecek kualitas kayu dolken sebelum bayar?"
    jawaban: "Kami siap COD ke lokasi Anda di Gowa. Tim akan dampingi pengecekan: pastikan tidak bengkok, tidak retak, diameter sesuai pesanan. Bayar setelah puas."
    icon: "bi-clipboard-check"

# ============================================================================
# SECTION FAQ - PRODUK (REQUIRED - min 2 items)
# ============================================================================
faq_produk:
  - pertanyaan: "Apakah kayu dolken perlu perawatan khusus di Gowa?"
    jawaban: "Tidak perlu perawatan khusus. Kayu Dolken tahan cuaca ekstrim Gowa — dari panas pesisir Sungguminasa hingga dingin pegunungan Malino. Untuk aplikasi outdoor di area Pallangga atau Biringbulu bisa tambah coating alami agar warna makin awet."
    icon: "bi-tools"
  - pertanyaan: "Apakah bisa custom panjang kayu dolken?"
    jawaban: "Bisa. Standar panjang 4 meter, kami bisa sesuaikan untuk kebutuhan proyek spesifik Anda di Gowa — hubungi 081311400177 untuk konsultasi ukuran."
    icon: "bi-rulers"

# ============================================================================
# SECTION FAQ - PENGIRIMAN (REQUIRED - min 1 item)
# ============================================================================
faq_pengiriman:
  - pertanyaan: "Berapa lama pengiriman ke Gowa?"
    jawaban: "Pengiriman 5-7 hari kerja ke seluruh Gowa, gratis ongkir untuk area Sungguminasa (ITC, kota), Malino (wisata pegunungan), Pallangga (agrowisata), dan Bontonompo (perkebunan kopi). Kami pakai armada terpercaya dan picker berpengalaman Gowa."
    icon: "bi-truck"

# ============================================================================
# SECTION RELEVANSI KAYU DOLKEN (REQUIRED)
# ============================================================================
# ============================================================================
relevansi_kayu_dolken:
  karakteristik_iklim: "Gowa memiliki iklim tropis dengan dua musim — kemarau panas di pesisir Sungguminasa & Pallangga, dan curah hujan tinggi di pegunungan Malino & Tinggimoncong. Kayu Dolken tahan terhadap kelembaban tinggi pesisir dan cuaca dingin ekstrem pegunungan, solusi konstruksi ideal untuk seluruh wilayah Gowa."
  keunggulan_lokal: "Sifat kayu yang <strong>tahan air, tahan rayap, dan tahan cuaca ekstrem</strong> sangat cocok untuk aplikasi seperti:"
  aplikasi_lokal:
    - nama: "Gazebo & villa pegunungan di kawasan wisata Malino"
      icon: "bi-check-circle-fill"
    - nama: "Pagar & gate rumah perumahan di Sungguminasa & Somba Opu"
      icon: "bi-check-circle-fill"
    - nama: "Dek & kolam renang outdoor di area pesisir Pallangga & Biringbulu"
      icon: "bi-check-circle-fill"
    - nama: "Landscaping Islamic Center Gowa & Alun-Alun Sungguminasa"
      icon: "bi-check-circle-fill"

# ============================================================================
# SECTION TENTANG KOTA (REQUIRED) - HARUS RESEARCH PER KOTA
# ============================================================================
tentang_kota:
  tagline: "Pusat Niaga, Agrowisata & Sejarah Gowa"
  deskripsi_singkat: "Kabupaten Gowa adalah pusat pertumbuhan ekonomi dan pariwisata di Sulawesi Selatan, berbatasan langsung dengan Makassar."
  overview: "Kabupaten Gowa (luas 1.883 km², populasi ~765.000 jiwa, 18 kecamatan & 167 kelurahan/desa) merupakan daerah strategis yang menyatu dengan Makassar. Perekonomian Gowa ditopang oleh sektor perdagangan (Pasar Sentral Sungguminasa), agrowisata (kopi arabika Malino), dan properti yang tumbuh pesat."

  # REQUIRED: EXACTLY 2 cards - Topik bebas, format tetap!
  # Card bisa tentang: sejarah, ekonomi, budaya, kuliner, wisata, atau apapun menarik dari kota ini
  tentang_kota_1:
    - judul: "Sejarah & Warisan Kerajaan Gowa"
      icon: "bi-clock-history"
      subjudul: "Dari 'Ayam Jantan dari Timur' hingga Pusat Niaga Modern"
      icon_subjudul: "bi-book"
      deskripsi: "Kabupaten Gowa memiliki sejarah panjang sebagai pusat Kerajaan Gowa yang legendaris. Di bawah kepemimpinan Sultan Hasanuddin (1629-1670) yang dijuluki 'Ayam Jantan dari Timur', Gowa mencapai puncak kejayaannya sebagai pusat perdagangan rempah-rempah dan kekuatan maritim terbesar di Indonesia Timur. Warisan kerajaan masih terasa kuat di Gowa modern — rumah adat, tradisi budaya, dan nilai kebersamaan masih dijunjung. Situs-situs bersejarah seperti Makam Raja-Raja Gowa dan Masjid Tua Katangka di Kelurahan Katangka, Somba Opu, menjadi sakbis perjalanan panjang Gowa dari masa kejayaan menuju era modern."
      fakta:
        - "Kerajaan Gowa menguasai jalur perdagangan rempah Indonesia Timur pada abad ke-16 hingga ke-17"
        - "Benteng Fort Rotterdam di Makassar adalah saksi bisu perlawanan Sultan Hasanuddin melawan VOC Belanda"
        - "Bahasa Makassar (Mangkasara') masih aktif digunakan sehari-hari oleh masyarakat Gowa"
    - judul: "Ekonomi & Potensi Agrowisata Gowa"
      icon: "bi-shop"
      subjudul: "Kopi Arabika Malino hingga Pasar Rakyat Sungguminasa"
      icon_subjudul: "bi-graph-up"
      deskripsi: "Perekonomian Gowa didorong oleh sektor perdagangan dan pertanian yang kuat. Pasar Sentral Sungguminasa menjadi pusat transaksi kayu Dolken, hasil bumi, dan barang kebutuhan pokok terbesar di kawasan timur Sulawesi Selatan. Sektor pertanian menjadi andalan dengan kopi arabika Malino yang mendunia — ditanam di ketinggian 1.000+ mdpl dengan cita rasa unik. Sektor properti di Gowa juga tumbuh fantastis, dengan banyak perumahan baru di Sungguminasa, Pallangga, dan Somba Opu yang menjadi penyangga permukiman Makassar. Pertumbuhan ekonomi Gowa menempatkannya sebagai salah satu daerah dengan investasi terbesar di Sulsel."
      fakta:
        - "Kopi arabika Malino menempati peringkat pertama produksi kopi di Sulawesi Selatan"
        - "Pasar Sentral Sungguminasa adalah pusat perdagangan kayu Dolken terbesar di Sulsel"
        - "Pertumbuhan properti Gowa 2x lipat rata-rata Sulsel didorong harga tanah lebih murah"

  # REQUIRED: EXACTLY 2 cards - Topik bebas, format tetap!
  # Card bisa tentang: landmark, pendidikan, bisnis, infrastruktur, atau apapun tentang kota ini
  tentang_kota_2:
    - judul: "Destinasi Wisata & Landmark Ikonik"
      icon: "bi-pin-map"
      subjudul: "Malino Highlands, Bili-Bili Dam & Islamic Center"
      icon_subjudul: "bi-star"
      deskripsi: "Gowa memiliki destinasi wisata pegunungan terpopuler di Sulawesi Selatan — Malino Highlands. Hamparan kebun teh, hutan pinus, dan udara sejuk (15-25°C) menjadikannya tujuan favorit keluarga. Bili-Bili Dam menjadi ikon infrastruktur dengan waduk luas dan pemandangan perbukitan. Islamic Center Gowa dengan arsitektur megah adalah landmark spiritual dan edukasi di Sungguminasa."
      list_item:
        - "<strong>Malino Highlands</strong> — Destinasi wisata pegunungan dengan kebun teh, pinus, dan udara sejuk — favorit wisatawan dari Makassar & sekitarnya"
        - "<strong>Bili-Bili Dam</strong> — Bendungan raksasa dengan waduk indah, cocok untuk foto, piknik, dan menikmati matahari terbenam"
        - "<strong>Islamic Center Gowa</strong> — Pusat keagamaan megah di Sungguminasa dengan arsitektur Islam modern yang menawan"
        - "<strong>Alun-Alun Sungguminasa</strong> — Ruang terbuka hijau pusat kota yang ramai setiap akhir pekan"
    - judul: "Kuliner Khas & Pusat Oleh-Oleh"
      icon: "bi-cup"
      subjudul: "Kopi Malino, Pisang Epe & Oleh-Oleh Gowa"
      icon_subjudul: "bi-star"
      deskripsi: "Kuliner Gowa menawarkan cita rasa autentik Sulawesi Selatan. Kopi arabika Malino menjadi primadona dengan cita rasa fruity dan acidity rendah, ditanam di dataran tinggi dingin Malino. Pisang Epe Gowa — pisang bakar khas yang mudah ditemukan di sepanjang poros Gowa-Makassar — menjadi camilan favorit wisatawan."
      list_item:
        - "<strong>Kopi Arabika Malino</strong> — Kopi specialty khas dataran tinggi Malino, ditanam di ketinggian 1.000+ mdpl, cita rasa unik"
        - "<strong>Pisang Epe Gowa</strong> — Pisang bakar legit khas Sulawesi, mudah ditemukan di Gowa-Makassar"
        - "<strong>Oleh-Oleh Pasar Sentral</strong> — Pusat oleh-oleh khas Gowa di Pasar Sentral Sungguminasa"
      info_tambahan: "Pusat oleh-oleh dan kuliner khas Gowa terkonsentrasi di sepanjang poros Sungguminasa-Malino dan Pasar Sentral Sungguminasa."
# ============================================================================
# SECTION SOCIAL METRICS (REQUIRED)
comment_count: 12
share_count: 7
---

<!-- ========================================================================
     CONTENT SECTION - DO NOT MODIFY
     Bagian ini adalah template standar untuk semua artikel post_with_product
     HANYA ganti {NAMA_KOTA} di block--jual-kayu-dolken-terdekat.html
     ======================================================================== -->

<section id="hero-jual-kayu-dolken">
  {% include reusable/post-with-city/block--hero-jual-kayu-dolken.html %}
</section>

<section id="mengapa-memilih-kami">
  {% include reusable/block--mengapa-memilih-kami.html %}
</section>

<section id="area-pengiriman-kayu-dolken">
  {% include reusable/block--area-pengiriman-kayu-dolken.html %}
</section>

<section id="keunggulan-kayu-dolken-gelam">
  {% include reusable/block--keunggulan-kayu-dolken-gelam.html %}
</section>

<section id="jual-kayu-dolken-terdekat">
{% include reusable/block--jual-kayu-dolken-terdekat.html
   nama_kota="Gowa"
%}
</section>

<section id="aplikasi-kayu-dolken-gelam">
  {% include reusable/block--aplikasi-kayu-dolken-gelam.html %}
</section>

<section id="cara-pemesanan">
  {% include reusable/block--cara-pemesanan-kayu-dolken.html %}
</section>

<section id="studi-kasus-proyek">
  {% include reusable/block--studi-kasus-proyek.html %}
</section>

<section id="testimoni-pelanggan">
  {% include reusable/block--testimoni-pelanggan.html %}
</section>

<section id="tips-memilih-ukuran">
  {% include reusable/block--tips-memilih-ukuran-kayu-dolken.html %}
</section>

<section id="faq-kayu-dolken">
  {% include reusable/block--faq-kayu-dolken.html %}
</section>

<section id="tentang-kota-kami">
  {% include reusable/block--tentang-kota-kami.html %}
</section>

<section id="relevansi-kayu-dolken">
  {% include reusable/block--relevansi-kayu-dolken.html %}
</section>

<section id="hubungi-kami">
  {% include reusable/block--hubungi-kami.html %}
</section>

<!-- Related Products Section (Part of article content) -->
<div id="related-products" class="article-related-products mt-5">
  {% include reusable/block--related-product-last-modified.html %}
</div>
