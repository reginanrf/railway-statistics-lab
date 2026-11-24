# ==== mod_tentang.R =================================================
# Halaman Tentang. Isi nama & NIM anggota dan sumber dataset sebelum presentasi.

mod_tentang_ui <- function(id) {
  tagList(
    page_header("Tentang", sub = "Tujuan aplikasi, metode, rumus, dan batasan analisis."),
    page_body(
      div(class = "card", h3("Railway Statistics Lab · v0.1"),
          p("Aplikasi untuk mengelola dataset dan menganalisis secara deskriptif pola jumlah penumpang kereta api menurut jam keberangkatan dan jenis hari. Bukan sistem pemesanan tiket, pelacakan langsung, atau sistem operasional KAI."),
          p(strong("Anggota kelompok"), tags$br(),
            "· Aziza Putri Amelia (2407784)", tags$br(),
            "· Regina Nur Fadhilah (2406043)", tags$br(),
            "· Siti Amalia Putri (2406274)"),
          p(strong("Sumber dataset: "),
            "Data jumlah penumpang bulanan tahun 2025 dari Badan Pusat Statistik (BPS) dan data jadwal keberangkatan Commuter Line dari repositori GitHub dedewanta. Kedua sumber diolah dan digabungkan untuk membentuk dataset analisis. Data contoh lainnya bersifat simulasi."),
          p(strong("Materi statistik: "), "ukuran pemusatan, penyebaran, posisi, distribusi frekuensi, tabulasi silang, perbandingan deskriptif.")),
      div(class = "card", h3("Dataset Jabodetabek 2025 (template tanggal)"),
          p("Dataset dibentuk dengan menggabungkan data jumlah penumpang bulanan dari BPS dan data jadwal keberangkatan Commuter Line dari GitHub. Penggabungan dilakukan menggunakan template tanggal 1 Januari–31 Desember 2025."),
          tags$ul(class = "ip",
                  tags$li(strong("Sumber data jumlah penumpang: "),
                          "Badan Pusat Statistik (BPS), tabel Jumlah Penumpang Kereta Api. Data yang digunakan berupa total penumpang bulanan tahun 2025. ",
                          tags$a(href = "https://www.bps.go.id/id/statistics-table/2/NzIjMg==/jumlah-penumpang-kereta-api",
                                 target = "_blank", "Lihat sumber BPS"),
                          " (diakses 24 November 2026)."),

                  tags$li(strong("Sumber data jadwal: "),
                          "dedewanta, file commuter_line_schedule.csv pada repositori scraping-krl-jabodetabek di GitHub. Data digunakan sebagai acuan informasi stasiun dan jam keberangkatan. ",
                          tags$a(href = "https://github.com/dedewanta/scraping-krl-jabodetabek/blob/master/commuter_line_schedule.csv",
                                 target = "_blank", "Lihat dataset jadwal"),
                          " (diakses 24 November 2026)."),

                  tags$li(strong("Pengolahan data: "),
                          "Total penumpang bulanan dibagi ke setiap tanggal dengan asumsi jumlah penumpang pada akhir pekan dan hari libur sebesar 77,5% dari hari kerja, merujuk rata-rata KAI Commuter. Selanjutnya, jumlah penumpang dialokasikan ke jam dan stasiun secara proporsional berdasarkan jumlah keberangkatan pada jadwal. Hari libur ditentukan berdasarkan SKB 3 Menteri tahun 2025. Lintas Bandara (BST) tidak diikutkan."),

                  tags$li(strong("Hasil pengolahan: "),
                          "Dataset mencakup 81 stasiun dengan rincian jam keberangkatan selama 365 hari. Total jumlah penumpang setiap bulan disesuaikan dengan angka BPS. Nilai pada tingkat tanggal, jam, dan stasiun merupakan hasil estimasi berdasarkan asumsi alokasi, bukan hasil pencacahan langsung.")
          )
      ),
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
                  tags$li("Jadwal/frekuensi kereta bukan jumlah penumpang; dataset yang hanya berisi jadwal tanpa jumlah penumpang tidak dapat dianalisis, kecuali digabung dengan total penumpang seperti pada dataset Jabodetabek 2025."),
                  tags$li("Hasil analisis dataset Jabodetabek 2025 mencerminkan asumsi pengolahannya dan tidak mewakili pola penumpang sebenarnya."),
                  tags$li("Pemrosesan berjalan lokal; data tidak dikirim ke server."),
                  tags$li("Baris kosong, tidak valid, negatif, dan duplikat dikeluarkan dari analisis."))))
  )
}

mod_tentang_server <- function(id) moduleServer(id, function(input, output, session) {})
