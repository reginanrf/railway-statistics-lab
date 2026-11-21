# ==== mod_data.R ====================================================
# Halaman Data: unggah, ringkasan, validasi, filter, preview, unduh.
# Penanggung jawab: Anggota Data

mod_data_ui <- function(id) {
  ns <- NS(id)
  tagList(
    page_header("Data", sub = "Unggah, periksa, filter, dan unduh dataset."),
    div(class = "g rsl-data-grid",
        div(
          div(class = "card", h3("Unggah dataset"),
              fileInput(ns("berkas"), NULL, accept = c(".csv", ".xlsx", ".xls"), buttonLabel = "Pilih file CSV / Excel", placeholder = "Belum ada file"),
              actionButton(ns("contoh"), "Muat contoh (simulasi)", class = "btn s"),
              p(class = "mu mt-2", "Kolom wajib: tanggal, jam_keberangkatan, jumlah_penumpang. Opsional: hari, jenis_hari, stasiun. Satu baris = jumlah penumpang pada satu tanggal, satu jam, dan satu stasiun (jika ada)."),
              uiOutput(ns("status"))),
          uiOutput(ns("isu")),
          uiOutput(ns("ui_ringkasan"))),
        div(
          uiOutput(ns("ui_kosong")),
          conditionalPanel("output.ada_data", ns = ns,
                           div(class = "card", h3("Filter dataset"), mod_filter_ui(ns("filter")),
                               downloadButton(ns("unduh"), "Unduh data terfilter (CSV)", class = "btn s btn-sm")),
                           div(class = "card", h3("Data preview"), DT::DTOutput(ns("preview"))))))
  )
}

mod_data_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns
    data_f <- mod_filter_server("filter", reactive(state$data))

    observeEvent(input$berkas, {
      f <- input$berkas
      hasil <- withProgress(message = "Membaca dataset…", {
        tryCatch(proses_dataset(baca_berkas(f$datapath, f$name)),
                 error = function(e) list(data = NULL, status = "bad", info = NULL,
                                          issues = list(buat_isu("error", paste("Gagal membaca file:", conditionMessage(e))))))
      })
      muat_ke_state(state, hasil, f$name)
    })
    observeEvent(input$contoh, {
      muat_ke_state(state, proses_dataset(baca_berkas("data/contoh_simulasi.csv", "contoh_simulasi.csv")), "contoh_simulasi.csv")
    })

    output$status <- renderUI(div("File: ", strong(state$file %||% "–"), " ", badge_status(state$status)))
    output$isu <- renderUI({
      tagList(if (grepl("simulasi", state$file %||% "")) div(class = "msg wr", "Data contoh ini SIMULASI untuk demo alur aplikasi, bukan data penumpang aktual."),
              kotak_isu(state$issues))
    })
    output$ui_ringkasan <- renderUI({
      req(state$info)
      div(class = "card", h3("Ringkasan dataset"), tableOutput(ns("ringkasan")))
    })
    output$ringkasan <- renderTable({
      req(state$info); i <- state$info
      data.frame(Keterangan = c("Jumlah baris (asli)", "Jumlah kolom", "Baris dengan nilai kosong", "Baris duplikat", "Baris valid dipakai"),
                 Nilai = c(i$n_baris, i$n_kolom, i$kosong, i$duplikat, i$valid))
    }, colnames = FALSE, align = "lr")

    # Filter & preview dibuat statis (agar modul filter terisi saat data masuk), hanya ditampilkan bila ada data
    output$ada_data <- reactive(!is.null(state$data))
    outputOptions(output, "ada_data", suspendWhenHidden = FALSE)
    output$ui_kosong <- renderUI(if (is.null(state$data) && identical(state$status, "none")) kartu_kosong())
    # Header tabel menampilkan tipe kolom (tanggal / waktu / numerik / kategori)
    output$preview <- DT::renderDT({
      req(state$data)
      d <- data_f()
      tipe <- vapply(names(d), function(n) {
        x <- d[[n]]
        if (inherits(x, c("Date", "POSIXct"))) "tanggal" else if (n == "jam") "waktu" else if (is.numeric(x)) "numerik" else "kategori"
      }, "")
      DT::datatable(d, rownames = FALSE, escape = FALSE, selection = "none",
                    colnames = paste0(names(d), "<small>", tipe, "</small>"),
                    options = list(pageLength = 15, dom = "ftip", language = list(search = "Cari:", info = "_TOTAL_ baris", paginate = list(previous = "‹", `next` = "›"))))
    })
    output$unduh <- downloadHandler(
      filename = function() "dataset_aktif.csv",
      content = function(file) utils::write.csv(data_f(), file, row.names = FALSE))
  })
}
