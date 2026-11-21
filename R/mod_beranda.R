# ==== mod_beranda.R =================================================
# Halaman Beranda: identitas aplikasi, ringkasan dataset aktif, pola utama.
# Penanggung jawab: Anggota Beranda/Tentang/UI

mod_beranda_ui <- function(id) {
  ns <- NS(id)
  tagList(
    div(class = "hero",
      span(class = "chip", "PROTOTYPE · v0.1"),
      h1("Railway Statistics Lab"),
      p("Aplikasi analisis statistik deskriptif pola jumlah penumpang kereta api berdasarkan jam keberangkatan dan jenis hari."),
      div(class = "rail")),
    uiOutput(ns("isi"))
  )
}

mod_beranda_server <- function(id, state, ke_halaman) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(input$ke_data, ke_halaman("data"))
    observeEvent(input$ke_analisis, ke_halaman("analisis"))

    output$isi <- renderUI({
      status_card <- bslib::card(
        div(strong("Dataset aktif: "), state$file %||% "–", " ", badge_status(state$status),
            if (!is.null(state$dimuat)) span(class = "text-muted", " · dimuat ", format(state$dimuat, "%H:%M:%S"))),
        div(actionButton(ns("ke_data"), "Unggah Dataset", class = "btn-primary"),
            actionButton(ns("ke_analisis"), "Mulai Analisis", class = "btn-outline-primary")))
      if (is.null(state$data)) return(tagList(status_card, kartu_kosong()))

      d <- state$data
      jam_top <- d |> dplyr::group_by(jam) |> dplyr::summarise(r = mean(jumlah_penumpang), .groups = "drop") |> dplyr::slice_max(r, n = 1)
      hari_top <- d |> dplyr::group_by(hari) |> dplyr::summarise(r = mean(jumlah_penumpang), .groups = "drop") |> dplyr::slice_max(r, n = 1)
      tagList(status_card,
        bslib::layout_columns(fill = FALSE,
          bslib::value_box("Total penumpang", fmt_id(sum(d$jumlah_penumpang), 0)),
          bslib::value_box("Jumlah pengamatan", fmt_id(nrow(d), 0)),
          bslib::value_box("Periode", paste(format(min(d$tanggal)), "–", format(max(d$tanggal)))),
          bslib::value_box("Jumlah hari", dplyr::n_distinct(d$tanggal))),
        bslib::layout_columns(fill = FALSE,
          bslib::value_box("Jam dengan rata-rata tertinggi", sprintf("%02d:00", jam_top$jam[1]), paste("rata-rata", fmt_id(jam_top$r[1]), "per pengamatan")),
          bslib::value_box("Hari dengan rata-rata tertinggi", hari_top$hari[1], paste("rata-rata", fmt_id(hari_top$r[1]), "per pengamatan"))),
        bslib::layout_columns(
          bslib::card(plotly::plotlyOutput(ns("g_jam"))),
          bslib::card(plotly::plotlyOutput(ns("g_jenis")))))
    })

    output$g_jam <- plotly::renderPlotly({
      req(state$data)
      tab <- agregasi(state$data, "jam", "mean"); tab$jam_lbl <- sprintf("%02d:00", tab$jam)
      grafik_bar(tab, "jam_lbl", "Rata-rata penumpang menurut jam", "Jam keberangkatan", "Rata-rata per pengamatan")
    })
    output$g_jenis <- plotly::renderPlotly({
      req(state$data)
      grafik_bar(agregasi(state$data, "jenis_hari", "mean"), "jenis_hari", "Rata-rata penumpang menurut jenis hari", "Jenis hari", "Rata-rata per pengamatan")
    })
  })
}
