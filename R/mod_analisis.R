# ==== mod_analisis.R ================================================
# Halaman Analisis (fitur inti): Statistik Deskriptif, Distribusi,
# Perbandingan Deskriptif. Visualisasi menyatu dengan hasil.
# Alur: pilih analisis -> filter/parameter -> Jalankan -> tabel + grafik + interpretasi.
# Penanggung jawab: Anggota Analisis

mod_analisis_ui <- function(id) {
  ns <- NS(id)
  kond <- function(nilai) sprintf("input['%s'] == '%s'", ns("jenis"), nilai)
  tagList(
    h2("Analisis"),
    uiOutput(ns("peringatan")),
    bslib::card(
      radioButtons(ns("jenis"), NULL, inline = TRUE,
        choices = c("Statistik Deskriptif" = "desc", "Distribusi" = "dist", "Perbandingan Deskriptif" = "cmp")),
      mod_filter_ui(ns("filter")),
      conditionalPanel(kond("desc"), selectInput(ns("variabel"), "Variabel", choices = "jumlah_penumpang")),
      conditionalPanel(kond("dist"),
        div(class = "filter-bar",
          selectInput(ns("dist"), "Jenis distribusi", c("Menurut jam" = "jam", "Menurut jenis hari" = "jenis", "Tabulasi silang" = "silang")),
          selectInput(ns("agregasi"), "Agregasi", c("Rata-rata" = "mean", "Total" = "total", "Persentase" = "persen")))),
      conditionalPanel(kond("cmp"),
        div(class = "filter-bar",
          selectInput(ns("kelompok"), "Kelompok", c("Hari kerja vs akhir pekan" = "kerja_akhir_pekan",
                                                    "Hari kerja vs hari libur" = "kerja_libur",
                                                    "Jam sibuk (06–09 & 16–19) vs lainnya" = "jam_sibuk")),
          selectInput(ns("ukuran"), "Ukuran grafik", c("Rata-rata", "Total", "Median", "Minimum", "Maksimum", "Std. deviasi")))),
      actionButton(ns("jalankan"), "Jalankan Analisis", class = "btn-primary")),
    uiOutput(ns("ui_hasil"))
  )
}

mod_analisis_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    data_f <- mod_filter_server("filter", reactive(state$data))

    output$peringatan <- renderUI(if (is.null(state$data)) kartu_kosong())

    hasil <- eventReactive(input$jalankan, {
      validate(need(!is.null(state$data), "Unggah dataset di menu Data terlebih dahulu."))
      df <- data_f()
      validate(need(nrow(df) > 0, "Tidak ada data pada filter yang dipilih."))
      withProgress(message = "Menghitung analisis…", value = 0.5, {
        out <- switch(input$jenis,
          desc = hitung_analisis_desc(df),
          dist = hitung_analisis_dist(df, input$dist, input$agregasi),
          cmp  = hitung_analisis_cmp(df, input$kelompok, input$ukuran))
        out$n_obs <- nrow(df); out$n_hari <- dplyr::n_distinct(df$tanggal)
        out
      })
    })

    output$ui_hasil <- renderUI({
      h <- hasil()
      tagList(
        bslib::card(class = "hl", bslib::card_header("Interpretasi otomatis"),
          tags$ul(lapply(h$interpretasi, tags$li)),
          p(class = "text-muted small mb-0", sprintf("Data dianalisis: %s pengamatan, %s hari. Deskripsi hasil, bukan klaim sebab-akibat.",
                                                     fmt_id(h$n_obs, 0), h$n_hari))),
        if (!is.null(h$catatan)) div(class = "alert alert-warning", h$catatan),
        bslib::card(bslib::card_header("Tabel hasil", downloadButton(ns("unduh_hasil"), "Unduh CSV", class = "btn-sm float-end")),
                    DT::DTOutput(ns("tabel"))),
        bslib::card(plotly::plotlyOutput(ns("plot1"))),
        if (!is.null(h$plot2)) bslib::card(plotly::plotlyOutput(ns("plot2"))))
    })
    output$tabel <- DT::renderDT(DT::datatable(hasil()$tabel, rownames = FALSE, options = list(pageLength = 15, dom = "tip")))
    output$plot1 <- plotly::renderPlotly(hasil()$plot1)
    output$plot2 <- plotly::renderPlotly(hasil()$plot2)
    output$unduh_hasil <- downloadHandler(
      filename = function() "hasil_analisis.csv",
      content = function(file) utils::write.csv(hasil()$tabel, file, row.names = FALSE))
  })
}

# ---- Fungsi pembantu per jenis analisis (mengembalikan list) -------------

hitung_analisis_desc <- function(df) {
  x <- df$jumlah_penumpang
  list(tabel = hitung_deskriptif(x), interpretasi = interpretasi_deskriptif(x),
       plot1 = grafik_histogram(df, "Histogram jumlah penumpang"),
       plot2 = if (dplyr::n_distinct(df$tanggal) > 1) grafik_garis(df, "Rata-rata penumpang menurut tanggal") else NULL)
}

hitung_analisis_dist <- function(df, jenis, ukuran) {
  satuan <- c(total = "total penumpang", mean = "rata-rata per pengamatan", persen = "% dari total")[[ukuran]]
  catatan <- if (ukuran == "total") "Total dipengaruhi jumlah hari/pengamatan tiap kelompok (lihat kolom pengamatan dan hari_diamati). Untuk membandingkan kelompok, gunakan rata-rata." else NULL
  bulat <- function(t) dplyr::mutate(t, dplyr::across(where(is.numeric), ~ round(.x, 2)))
  if (jenis == "silang") {
    tab <- agregasi(df, c("jam", "jenis_hari"), ukuran)
    i <- which.max(tab$nilai)
    wide <- tidyr::pivot_wider(bulat(tab[c("jam", "jenis_hari", "nilai")]), names_from = jenis_hari, values_from = nilai)
    return(list(tabel = wide, catatan = catatan,
      interpretasi = sprintf("Kombinasi tertinggi (%s) adalah pukul %02d:00 pada %s (%s).", satuan, tab$jam[i], tolower(tab$jenis_hari[i]), fmt_id(tab$nilai[i])),
      plot1 = grafik_heatmap(tab, paste("Heatmap jam × jenis hari:", satuan), satuan), plot2 = NULL))
  }
  if (jenis == "jam") {
    tab <- agregasi(df, "jam", ukuran); tab$jam_lbl <- sprintf("%02d:00", tab$jam)
    return(list(tabel = bulat(tab[c("jam_lbl", "nilai", "pengamatan", "hari_diamati")]), catatan = catatan,
      interpretasi = interpretasi_agregasi(tab, "jam_lbl", ukuran, "pukul "),
      plot1 = grafik_bar(tab, "jam_lbl", paste("Distribusi menurut jam:", satuan), "Jam keberangkatan", satuan, ukuran == "persen"), plot2 = NULL))
  }
  tab <- agregasi(df, "jenis_hari", ukuran)
  list(tabel = bulat(tab[c("jenis_hari", "nilai", "pengamatan", "hari_diamati")]), catatan = catatan,
    interpretasi = interpretasi_agregasi(tab, "jenis_hari", ukuran, "kelompok "),
    plot1 = grafik_bar(tab, "jenis_hari", paste("Distribusi menurut jenis hari:", satuan), "Jenis hari", satuan, ukuran == "persen"), plot2 = NULL)
}

hitung_analisis_cmp <- function(df, kelompok, ukuran) {
  df2 <- siapkan_kelompok(df, kelompok)
  cmp <- bandingkan(df2)
  validate(need(!is.null(cmp), "Salah satu kelompok tidak memiliki data pada filter ini (mis. kategori 'Hari libur' tidak ada di dataset)."))
  g <- cmp$kelompok; r <- cmp$tabel[cmp$tabel$Ukuran == ukuran, ]
  tab_plot <- tibble::tibble(kelompok = g, nilai = c(r[[g[1]]], r[[g[2]]]))
  list(tabel = dplyr::mutate(cmp$tabel, dplyr::across(where(is.numeric), ~ round(.x, 2))),
       catatan = "Perbandingan ini bersifat deskriptif, bukan uji signifikansi statistik.",
       interpretasi = interpretasi_perbandingan(cmp, ukuran),
       plot1 = grafik_bar(tab_plot, "kelompok", paste("Perbandingan:", ukuran), "Kelompok", ukuran),
       plot2 = grafik_boxplot(df2, "Sebaran jumlah penumpang per kelompok"))
}
