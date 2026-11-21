# ==== mod_analisis.R ================================================
# Halaman Analisis (fitur inti): Statistik Deskriptif, Distribusi,
# Perbandingan Deskriptif. Visualisasi menyatu dengan hasil.
# Alur: pilih analisis -> filter/parameter -> Jalankan -> tabel + grafik + interpretasi.
# Penanggung jawab: Anggota Analisis

mod_analisis_ui <- function(id) {
  ns <- NS(id)
  kond <- function(nilai) sprintf("input['%s'] == '%s'", ns("jenis"), nilai)
  tagList(
    page_header("Analisis", lencana = uiOutput(ns("lencana"), inline = TRUE),
                tabs = div(class = "utabs",
                           radioButtons(ns("jenis"), NULL, inline = TRUE,
                                        choices = c("Statistik Deskriptif" = "desc", "Distribusi" = "dist", "Perbandingan Deskriptif" = "cmp")))),
    div(class = "split",
        div(class = "card cfg", h3("Pengaturan analisis"),
            mod_filter_ui(ns("filter")),
            div(class = "fb",
                conditionalPanel(kond("desc"), selectInput(ns("variabel"), "Variabel", choices = "jumlah_penumpang")),
                conditionalPanel(kond("dist"),
                                 selectInput(ns("dist"), "Jenis distribusi", c("Menurut jam" = "jam", "Menurut jenis hari" = "jenis", "Tabulasi silang" = "silang")),
                                 selectInput(ns("agregasi"), "Agregasi", c("Rata-rata" = "mean", "Total" = "total", "Persentase" = "persen"))),
                conditionalPanel(kond("cmp"),
                                 selectInput(ns("kelompok"), "Kelompok", c("Hari kerja vs akhir pekan" = "kerja_akhir_pekan",
                                                                           "Hari kerja vs hari libur" = "kerja_libur",
                                                                           "Jam sibuk (06–09 & 16–19) vs lainnya" = "jam_sibuk")),
                                 selectInput(ns("ukuran"), "Ukuran grafik", c("Rata-rata", "Total", "Median", "Minimum", "Maksimum", "Std. deviasi"))),
                actionButton(ns("jalankan"), "Jalankan Analisis", class = "btn")),
            uiOutput(ns("n_sesuai"))),
        div(class = "res", uiOutput(ns("ui_hasil"))))
  )
}

mod_analisis_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    data_f <- mod_filter_server("filter", reactive(state$data))

    output$lencana <- renderUI({
      req(state$data)
      if (grepl("simulasi", state$file %||% "")) span(class = "badge wr", "Data Simulasi") else span(class = "badge ok", "Data Aktual")
    })
    output$n_sesuai <- renderUI({
      req(state$data)
      span(class = "mu", sprintf("%s pengamatan sesuai filter.", fmt_id(nrow(data_f()), 0)),
           if (identical(input$jenis, "cmp") && identical(input$kelompok, "jam_sibuk"))
             " Aturan jam sibuk (ditetapkan eksplisit): 06.00–09.59 dan 16.00–19.59.")
    })

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
        out$jenis <- input$jenis
        out
      })
    })

    output$ui_hasil <- renderUI({
      if (is.null(state$data)) return(kartu_kosong())
      if (input$jalankan == 0) return(div(class = "card empty", "Atur analisis lalu tekan ", strong("Jalankan Analisis"), "."))
      h <- hasil()
      judul <- c(desc = "Statistik Deskriptif", dist = "Distribusi", cmp = "Perbandingan Deskriptif")[[h$jenis]]
      nilai <- function(u) h$tabel$Nilai[h$tabel$Ukuran == u]
      tagList(
        div(class = "fb", h3(style = "margin:0", paste("Hasil:", judul)),
            downloadButton(ns("unduh_hasil"), "Unduh tabel hasil (CSV)", class = "btn s btn-sm")),
        div(class = "card", h3("Interpretasi otomatis"),
            tags$ul(class = "ip", lapply(h$interpretasi, tags$li)),
            div(class = "mu", sprintf("Deskripsi hasil pada data yang dianalisis, bukan klaim sebab-akibat. Data: %s pengamatan, %s hari.",
                                      fmt_id(h$n_obs, 0), h$n_hari))),
        if (h$jenis == "desc") div(class = "g g4",
                                   kartu_stat("N", nilai("N")), kartu_stat("Mean", nilai("Mean")),
                                   kartu_stat("Median", nilai("Median")), kartu_stat("Std. deviasi", nilai("Standar deviasi"))),
        div(class = "card", DT::DTOutput(ns("tabel"))),
        div(class = "card", plotly::plotlyOutput(ns("plot1"))),
        if (!is.null(h$plot2)) div(class = "card", plotly::plotlyOutput(ns("plot2"))),
        if (!is.null(h$catatan)) div(class = "msg wr", h$catatan))
    })
    output$tabel <- DT::renderDT(DT::datatable(hasil()$tabel, rownames = FALSE, selection = "none", options = list(pageLength = 15, dom = "tip", paging = nrow(hasil()$tabel) > 15)))
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
