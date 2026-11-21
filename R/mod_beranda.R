# ==== mod_beranda.R =================================================
# Halaman Beranda: identitas aplikasi, ringkasan dataset aktif, pola utama.
# Penanggung jawab: Anggota Beranda/Tentang/UI

# Pintasan (kartu klik) saat belum ada dataset: id, judul, deskripsi, ikon, gradasi warna
pintasan_beranda <- list(
  list(id = "sc_data", t = "Data", d = "Unggah CSV/Excel, validasi, tinjauan, dan filter dataset.", ic = "Data", g = c("#F28A2E", "#F2A93B")),
  list(id = "sc_desc", t = "Statistik Deskriptif", d = "Mean, median, modus, varians, kuartil, persentil, dan histogram.", ic = "Stat", g = c("#3B7BFF", "#5B4BE8")),
  list(id = "sc_dist", t = "Distribusi", d = "Menurut jam, jenis hari, dan tabulasi silang.", ic = "Dist", g = c("#8A3FD8", "#D9468A")),
  list(id = "sc_cmp", t = "Perbandingan", d = "Hari kerja vs akhir pekan dan perbandingan antarperiode.", ic = "Cmp", g = c("#17A86B", "#3B9BE8")),
  list(id = "sc_tentang", t = "Tentang", d = "Metode, rumus, batasan, dan sumber data.", ic = "Tentang", g = c("#6A6B8A", "#8A3FD8")))

mod_beranda_ui <- function(id) {
  ns <- NS(id)
  tagList(page_header("Beranda"), uiOutput(ns("isi")))
}

mod_beranda_server <- function(id, state, ke_halaman) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    observeEvent(input$ke_data, ke_halaman("data"))
    observeEvent(input$ke_analisis, ke_halaman("analisis"))
    observeEvent(input$sc_data, ke_halaman("data"))
    observeEvent(input$sc_desc, ke_halaman("analisis", "desc"))
    observeEvent(input$sc_dist, ke_halaman("analisis", "dist"))
    observeEvent(input$sc_cmp, ke_halaman("analisis", "cmp"))
    observeEvent(input$sc_tentang, ke_halaman("tentang"))

    output$isi <- renderUI({
      if (is.null(state$data)) {
        hero <- div(class = "hero", h2("Railway Statistics Lab"),
                    p("Aplikasi analisis statistik deskriptif pola jumlah penumpang kereta api berdasarkan jam keberangkatan dan jenis hari."),
                    actionButton(ns("ke_data"), "Buka Data", class = "btn"),
                    actionButton(ns("ke_analisis"), "Mulai Analisis", class = "btn s"),
                    div(class = "rail"))
        info <- div(class = "card infobar",
                    div(strong("Dataset Aktif:"), " ", span(class = "mu", state$file %||% "Belum ada dataset")), badge_status(state$status))
        if (identical(state$status, "bad")) {
          return(tagList(hero, info, kotak_isu(state$issues),
                         div(class = "card empty", h3("Dataset belum dapat dipakai"),
                             "Periksa kolom wajib (tanggal, jam_keberangkatan, jumlah_penumpang) lalu unggah ulang file di menu Data.")))
        }
        kartu <- lapply(pintasan_beranda, function(p)
          tags$button(id = ns(p$id), type = "button", class = "sct action-button",
                      span(class = "sic", style = sprintf("background:linear-gradient(135deg,%s,%s)", p$g[1], p$g[2]), ikon(p$ic)),
                      tags$b(p$t), tags$p(p$d)))
        return(tagList(hero, info, div(class = "g sc3", kartu)))
      }

      d <- state$data
      sim <- grepl("simulasi", state$file %||% "")
      jam_top <- d |> dplyr::group_by(jam) |> dplyr::summarise(r = mean(jumlah_penumpang), .groups = "drop") |> dplyr::slice_max(r, n = 1)
      hari_top <- d |> dplyr::group_by(hari) |> dplyr::summarise(r = mean(jumlah_penumpang), .groups = "drop") |> dplyr::slice_max(r, n = 1)
      tagList(
        div(class = "band",
            div(tags$small("DATASET AKTIF"),
                div(class = "bn", state$file, if (sim) span(class = "badge wr", "Data Simulasi"), badge_status(state$status))),
            div(actionButton(ns("ke_analisis"), "Mulai Analisis", class = "btn"),
                actionButton(ns("ke_data"), "Buka Data", class = "btn s"))),
        kotak_isu(state$issues),
        div(class = "g g4",
            kartu_stat("Total penumpang", fmt_id(sum(d$jumlah_penumpang), 0)),
            kartu_stat("Jumlah pengamatan", fmt_id(nrow(d), 0)),
            kartu_stat("Periode", tagList(format(min(d$tanggal)), tags$br(), "s.d. ", format(max(d$tanggal))), kecil = TRUE),
            kartu_stat("Jumlah hari", dplyr::n_distinct(d$tanggal))),
        div(class = "g g2",
            kartu_stat("Jam dengan rata-rata penumpang tertinggi", sprintf("%02d:00", jam_top$jam[1]),
                       paste("rata-rata", fmt_id(jam_top$r[1]), "per pengamatan"), hi = TRUE),
            kartu_stat("Hari dengan rata-rata penumpang tertinggi", hari_top$hari[1],
                       paste("rata-rata", fmt_id(hari_top$r[1]), "per pengamatan"), hi = TRUE)),
        div(class = "g g2",
            div(class = "card", plotly::plotlyOutput(ns("g_jam"))),
            div(class = "card", plotly::plotlyOutput(ns("g_jenis")))))
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
