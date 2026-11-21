# Railway Statistics Lab

Aplikasi **R Shiny** untuk mengelola dataset dan menganalisis secara **deskriptif** pola jumlah penumpang kereta api berdasarkan **jam keberangkatan** dan **jenis hari**.

> Bukan sistem pemesanan tiket, pelacakan perjalanan langsung, atau sistem operasional KAI.

## Menu
Beranda · Data · Analisis (statistik deskriptif, distribusi, perbandingan deskriptif) · Tentang

## Menjalankan
Prasyarat: R ≥ 4.1 (memakai pipe `|>`), RStudio (disarankan), Git.

```r
# sekali saja, setelah clone
install.packages("renv")
renv::restore()          # memasang paket sesuai renv.lock
# jalankan aplikasi
shiny::runApp()
```
Klik **Muat contoh (simulasi)** di menu Data untuk mencoba tanpa file sendiri.

## Struktur
```
railway-statistics-lab/
├── app.R                  # titik masuk (UI utama + server) — hanya integrator
├── R/
│   ├── fct_data.R         # baca, validasi, transformasi dataset
│   ├── fct_statistik.R    # perhitungan statistik & interpretasi
│   ├── fct_grafik.R       # grafik ggplot2 → plotly
│   ├── mod_beranda.R      # modul halaman Beranda
│   ├── mod_data.R         # modul halaman Data
│   ├── mod_filter.R       # modul filter (dipakai Data & Analisis)
│   ├── mod_analisis.R     # modul halaman Analisis
│   ├── mod_tentang.R      # modul halaman Tentang
│   └── utils_ui.R         # komponen UI bersama
├── www/custom.css         # gaya (moodboard)
├── data/contoh_simulasi.csv   # data SIMULASI untuk demo
├── tests/testthat/        # uji perhitungan & validasi
├── docs/PANDUAN.md        # panduan kerja tim + GitHub
└── .github/pull_request_template.md
```

## Kolom dataset
Wajib: `tanggal`, `jam_keberangkatan`, `jumlah_penumpang`. Opsional: `hari`, `jenis_hari`, `stasiun`.
Satu baris = jumlah penumpang pada satu tanggal, satu jam keberangkatan (dan satu stasiun jika ada).

## Berkontribusi
Baca [docs/PANDUAN.md](docs/PANDUAN.md).
