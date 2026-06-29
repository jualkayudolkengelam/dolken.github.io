# Analisis Kebutuhan Workflow Agent

**Pertanyaan:** Banyak sekali request, token hanya untuk menghasilkan satu konten yang sudah ada templatenya; apakah perlu membuat workflow agent untuk mengelola proses ini?

## Patokan Utama
**Template:** `/home/mkt01/Public/dolken.github.io/public_html/TEMPLATES/TEMPLATE--post-with-city.md`
Template ini adalah *single source of truth* (sumber kebenaran tunggal) untuk struktur konten. Semua agen **tidak boleh mengubah struktur template**, hanya mengisi placeholder yang sudah ditentukan.

---

## Rekomendasi Agen & System Prompt

| Agent | Tugas | System Prompt |
|-------|-------|---------------|
| **Research** | Mengumpulkan data dan referensi per kota | "Anda adalah Research Agent. Tugas Anda mencari data akurat tentang [KOTA]:<br>• Data dasar: Luas, populasi, kecamatan/desa<br>• Topik 1 (Sejarah/Budaya): 3 fakta + deskripsi<br>• Topik 2 (Ekonomi/Agrowisata): Data + 3 fakta<br>• Topik  Topik 3 (Landmark/Wisata): 3-4 item + deskripsi<br>• Topik 4 (Kuliner/Oleh-oleh): 3 item + ciri khas<br>**Output:** JSON terstruktur." |
| **Writer** | Menyusun draf awal mengisi template | "Anda adalah Writer Agent. Terima data JSON dari Research + `TEMPLATE--post-with-city.md`.<br>• Isi SEMUA field YAML (`tagline`, `deskripsi_singkat`, `overview`, `tentang_kota_1`, `tentang_kota_2`, `relevansi_kayu_dolken`, `keunggulan_produk`, `aplikasi`, `studi_kasus`, `testimoni`, `tips`, `faq`, `area_pengiriman`, dll.)<br>• Ikuti struktur Nested List presisi (indent 2/4 spasi, array `-` item)<br>• Gunakan `<strong>` di `list_item` sesuai template<br>**Output:** File Markdown lengkap siap validasi." |
| **Editor** | Memperbaiki gaya bahasa & validasi sintaks | "Anda adalah Editor Agent. Validasi file dari Writer:<br>• **YAML Syntax**: Quotes lengkap (`"`), indentasi konsisten, tidak ada trailing whitespace<br>• **Bahasa**: Persuasif, profesional, natural (Bahasa Indonesia), tidak terasa AI<br>• **Completeness**: Tidak ada placeholder tertinggal (`tulis...`, `isi...`, `ganti...`)<br>**Output:** Markdown yang sudah dipoles & siap review." |
| **Reviewer** | Memastikan hasil sesuai permintaan & template | "Anda adalah Reviewer Agent. Verifikasi akhir sebelum commit:<br>• Bandingkan dengan `TEMPLATE--post-with-city.md` — tidak ada section hilang<br>• Path gambar benar (`assets/images/posts/jual-kayu-dolken-{kota}/001-004.webp`)<br>• Layout: `layout: node--post-with-city`<br>• Jika OK → `APPROVED`; jika tidak → kembali ke Editor dengan catatan." |

---

## Alur Kerja (Pipeline)
```
Input (Nama Kota)
     ↓
[Research] → data.json
     ↓
[Writer]   → draft.md (menggunakan TEMPLATE--post-with-city.md)
     ↓
[Editor]   → polished.md
     ↓
[Reviewer] → APPROVED / REJECT
     ↓
Git Commit & Push
```

---

## Keuntungan
- **Skalabilitas**: Request banyak dapat diparalelkan (Research paralel untuk banyak kota).
- **Efisiensi Token**: Tiap agen hanya konsumsi token untuk tugas spesifik, bukan seluruh pipeline sekaligus.
- **Traceability**: Setiap langkah tercatat (commit/message), memudahkan debugging.
- **Single Source of Truth**: Template tidak diubah oleh agen manapun, memastikan konsistensi struktur.

---

## Implementasi Teknis (Usulan)
1. **GitHub Actions Workflow** yang memicu `hermes-agent` dengan skill `autonomous-ai-agents` untuk tiap fase.
2. Atau gunakan `delegate_task` (Hermes) untuk spawn 4 sub-agent paralel/berurutan.
3. Setiap agen baca/tulis file di workspace terpisah (`/tmp/agent-research/`, `/tmp/agent-writer/`, dst.) lalu pass artifact ke agen berikutnya.

---

## Catatan Penting
- **Template jangan di-copy-edit** — agen harus *read* template lalu *write* output ke file baru (`_post_with_city/YYYY-MM-DD-jual-kayu-dolken-{kota}.md`).
- **YAML Nested List** (`tentang_kota_1`, `proyek_komersial`, `wilayah_pusat`, dll.) indentasi wajib konsisten — **Editor Agent** perlu validasi.
- **Gambar WebP**: 4 file per kota (`001-004.webp`) — Research/Writer perlu koordinasi asset preparation.

---

## Demo Agent Research (Executed)
Telah dijalankan via `delegate_task` untuk kota **Gowa**:
- **Duration**: 222 detik
- **Output**: `/tmp/research-output/gowa.json` (JSON struktur lengkap)
- **Fields terisi**: tagline, deskripsi_singkat, overview, sejarah, ekonomi, wisata, kuliner, relevansi, keunggulan, aplikasi, proyek_komersial, studi_kasus, testimoni, faq, area_pengiriman, wilayah, landmark

### Reusability Pattern
```bash
# Untuk Maros:
python3 /home/mkt01/Public/dolken.github.io/public_html/scripts/run-research-agent.py --city "Maros"
# Output otomatis: /tmp/research-output/maros.json

# Wrapper script:
/scripts/run-research-agent.py
#!/usr/bin/env python3
import json, sys
city = sys.argv[sys.argv.index('--city') + 1]
# delegate_task(...) with context=f"Target city: {city}"
```

---

---
## Next Steps
1. **Writer Agent**: Buat skrip auto-isi template dengan JSON output
2. **Editor Agent**: Validasi YAML via `yaml.safe_load()` setiap section
3. **Reviewer Agent**: Checklist otomatis sebelum commit
4. **Package as Hermes Skill**: Bundel seluruh workflow menjadi skill `jekyll_post_with_city`

---

## Skill Organization & Repository Strategy

### Option 1: Single Repo for Multiple Related Skills
```
github.com/yourname/hermes-skills/
├── jekyll_post_with_city/
│   ├── SKILL.md
│   ├── scripts/
│   │   ├── run-research-agent.py
│   │   ├── run-writer-agent.py
│   │   ├── run-editor-agent.py
│   │   └── run-reviewer-agent.py
│   └── templates/
│       └── TEMPLATE--post-with-city.md
├── jekyll_post_with_product/
│   ├── SKILL.md
│   └── scripts/
└── blog_automation_helper/
    ├── SKILL.md
    └── scripts/
```

**Pros:**
- Satu tempat untuk semua skill terkait
- Mudah maintenance dan versioning
- Shared dependencies (mis. common helper functions)
- One-time setup for Hermes skill discovery

**Cons:**
- Repo bisa menjadi besar jika banyak skill
- Tidak ideal jika skill sangat tidak terkait

### Option 2: Separate Repo per Skill
```
github.com/yourname/hermes-skill-jekyll-post-with-city/
├── SKILL.md
├── scripts/
└── templates/
```

**Pros:**
- Isolasi jelas per skill
- Mudah bagi pengguna lain untuk fork/install satu skill saja
- CI/CD terpisah per skill

**Cons:**
- Overhead manajemen banyak repo
- Duplikasi file yang sama (mis. helper scripts)

### Rekomendasi untuk Kasus Ini
Karena kita berfokus pada workflow konten Jekyll (post-with-city, post-with-product, post-with-event, dst.), **gunakan satu repo** untuk semua skill terkait konten. Contoh:
- `github.com/jualkayudolkengelam/hermes-content-skills/`

Di dalam repo tersebut, setiap skill memiliki direktori sendiri dengan:
```
.
├── jekyll_post_with_city/
├── jekyll_post_with_product/
├── jekyll_post_with_event/
└── shared/
    └── helpers.py  # utility functions untuk semua skill
```

---

## Cara Membuat Skill Hermes

1. **Buat direktori skill**:
   ```bash
   mkdir -p ~/.hermes/skills/jekyll_post_with_city
   ```

2. **Buat SKILL.md** (format standar):
   ```yaml
   # ~/.hermes/skills/jekyll_post_with_city/SKILL.md
   name: jekyll_post_with_city
   description: Workflow agent untuk generate Jekyll post dengan template post-with-city
   category: content-generation
   version: 1.0.0
   ```

3. **Tambahkan skrip dan template** ke dalam direktori skill:
   - `scripts/run-research-agent.py`
   - `scripts/run-writer-agent.py`
   - `templates/TEMPLATE--post-with-city.md` (copy dari project)

4. **Test skill secara lokal**:
   ```bash
   hermes agent run --skill jekyll_post_with_city --prompt "Generate post for Maros"
   ```

5. **Share via GitHub** (opsional):
   - Push repo ke GitHub
   - Pengguna lain bisa install dengan:
     ```bash
     hermes skill install github.com/jualkayudolkengelam/hermes-content-skills#jekyll_post_with_city
     ```

---

## Integrasi dengan Workflow Sekarang
Skill `jekyll_post_with_city` akan menggantikan alur manual yang kita lakukan sebelumnya:
- Langkah Research → Writer → Editor → Reviewer dijalankan otomatis via skill
- User cukup memberikan nama kota sebagai parameter
- Skill mengembalikan file Markdown yang siap commit ke `_post_with_city/`

Contoh penggunaan:
```bash
hermes skill run jekyll_post_with_city \
  --param city="Maros" \
  --output _post_with_city/2026-06-29-jual-kayu-dolken-maros.md
```

Ini akan:
1. Jalankan Research Agent untuk Maros
2. Isi template dengan hasil riset
3. Validasi YAML dan bahasa
4. Output file Markdown lengkap

---

## Cross-AI Compatibility (Generik)

### Skill Format yang Tool-Agnostic
Skill Hermes
Skill Hermes hanya berisi dokumentasi (`SKILL.md`) dan skrip Python — **tidak terikat Hermes runtime**. Design sudah generik agar dipanggil dari:
- **Hermes CLI**: `hermes skill run jekyll_post_with_city --param city="Maros"`
- **Claude Code CLI**: `claude-code-tools run-skill --skill-path path/to/jekyll_post_with_city`
- **GitHub Actions / CI**: `python3 entrypoint.py --city="Maros" --output draft.md`
- **Any Python environment**: `from jekyll_post_with_city import run; run(city="Maros")`

### Entrypoint Generik (entrypoint.py)
```python
#!/usr/bin/env python3
"""Entrypoint aplikasi generik. Tidak butuh Hermes CLI."""
import argparse, json, sys
from pathlib import Path

def main():
    parser = argparse.ArgumentParser(prog="jekyll_post_with_city")
    parser.add_argument("--city", required=True, help="Target kabupaten/kota")
    parser.add_argument("--template", required=True, help="Path ke TEMPLATE--post-with-city.md")
    parser.add_argument("--output", required=True, help="Path output .md")
    parser.add_argument("--format", choices=["json", "md"], default="md")
    args = parser.parse_args()

    # Panggil delegasi ke Hermes agent (jika tersedia) atau LLM API langsung
    from hermes_tools import execute_code  # opsional
    prompt = f"Research data untuk kota={args.city} untuk template kayu dolken. Output JSON only."
    result = execute_code(prompt=prompt)  # Hermes internal
    data = json.loads(result)

    template = Path(args.template).read_text()
    filled = fill_template(template, data)
    Path(args.output).write_text(filled)

if __name__ == "__main__":
    main()
```

### Cara AI Agent Lain (Claude Code, Copilot) Pakai
```bash
# Via load-skill (plugin Hermes-aware)
claude-code-tools load-skill ./jekyll_post_with_city/
claude-code-tools run-skill --skill jekyll_post_with_city --param city="Maros"

# Via entrypoint langsung (tidak butuh Hermes)
python3 ./jekyll_post_with_city/entrypoint.py \
  --city "Maros" \
  --template "./templates/TEMPLATE--post-with-city.md" \
  --output "./draft.md"
```

---

## Status Saat Ini

### Skill Sudah Di-Clone Lokal
**Lokasi**: `/home/mkt01/.hermes/skills/jeckyll_post`  *(note: typo "jeckyll" — seharusnya "jekyll")*

**Struktur yang diharapkan**:
```
/home/mkt01/.hermes/skills/jeckyll_post/
├── SKILL.md
├── scripts/
│   ├── run-research-agent.py
│   ├── run-writer-agent.py
│   ├── run-editor-agent.py
│   └── run-reviewer-agent.py
└── templates/
    └── TEMPLATE--post-with-city.md
```

### Next Actions
1. **Rename directory**: `mv /home/mkt01/.hermes/skills/jeckyll_post /home/mkt01/.hermes/skills/jekyll_post_with_city`
2. **Buat SKILL.md** dengan format standar
3. **Copy template** dari project ke `templates/`
4. **Tulis 4 skrip agen** (Research, Writer, Editor, Reviewer) + `entrypoint.py`
5. **Test** dengan `hermes skill run jekyll_post_with_city --param city="Maros"`

---
*File ini dibuat untuk diskusi & revisi lanjutan. Silakan berikan masukan mengenai struktur skill dan repo yang Anda prefer.*

---
*File ini dibuat untuk diskusi & revisi lanjutan.*