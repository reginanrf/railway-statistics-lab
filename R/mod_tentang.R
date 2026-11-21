# ==== mod_tentang.R =================================================
# Halaman Tentang. Isi nama anggota & sumber dataset sebelum presentasi.

mod_tentang_ui <- function(id) {
  tagList(
    page_header("Tentang", sub = "Tujuan aplikasi, metode, rumus, dan batasan analisis."),
    page_body(
      div(class = "card", h3("Railway Statistics Lab · v0.1 (prototype)"),
          p("Aplikasi untuk mengelola dataset dan menganalisis secara deskriptif pola jumlah penumpang kereta api menurut jam keberangkatan dan jenis hari. Bukan sistem pemesanan tiket, pelacakan langsung, atau sistem operasional KAI."),
          p(strong("Anggota kelompok: "), "(isi nama anggota)"),
          p(strong("Sumber dataset: "), "file yang diunggah pengguna (isi sumber data resmi). Data contoh bersifat simulasi."),
          p(strong("Materi statistik: "), "ukuran pemusatan, penyebaran, posisi, distribusi frekuensi, tabulasi silang, perbandingan deskriptif.")),
      div(class = "card", h3("Rumus dan metode"),
          tags$ul(class = "ip",
                  tags$li("Mean = Σx / n; Median = nilai tengah terurut; Modus = nilai paling sering."),
                  tags$li("Varians sampel = Σ(x − x̄)² / (n − 1); Standar deviasi = √varians; Range = maks − min."),
                  tags$li("Kuartil/persentil: interpolasi linear (quantile type 7)."),
                  tags$li("Rata-rata kelompok = rata-rata jumlah penumpang per baris pengamatan; persentase = nilai kelompok / total × 100."),
                  tags$li("Jenis hari turunan: Sabtu–Minggu = Akhir pekan, lainnya = Hari kerja. Hari libur hanya jika ada di kolom jenis_hari."),
                  tags$li("Jam sibuk (perbandingan): 06.00–09.59 dan 16.00–19.59; % beda = (A − B) / B × 100."))),
      div(class = "card", h3("Batasan"),
          tags$ul(class = "ip",
                  tags$li("Hanya analisis deskriptif; tidak ada uji signifikansi atau klaim sebab-akibat."),
                  tags$li("Jadwal/frekuensi kereta bukan jumlah penumpang; dataset tanpa jumlah penumpang aktual tidak dapat dianalisis."),
                  tags$li("Pemrosesan berjalan lokal; data tidak dikirim ke server."),
                  tags$li("Baris kosong, tidak valid, negatif, dan duplikat dikeluarkan dari analisis."))))
  )
}

mod_tentang_server <- function(id) moduleServer(id, function(input, output, session) {})
