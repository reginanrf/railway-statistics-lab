# ==== mod_data.R ====================================================
# Halaman Data: unggah, ringkasan, validasi, filter, preview, unduh.
# Penanggung jawab: Anggota Data

mod_data_ui <- function(id) {
  ns <- NS(id)
  tagList(
    h2("Data"),
    bslib::layout_columns(col_widths = c(4, 8),
      div(
        bslib::card(bslib::card_header("Unggah dataset"),
          fileInput(ns("berkas"), NULL, accept = c(".csv", ".xlsx", ".xls"), buttonLabel = "Pilih file", placeholder = "CSV / Excel"),
          actionButton(ns("contoh"), "Muat contoh (simulasi)", class = "btn-outline-primary btn-sm"),
          p(class = "text-muted small mt-2", "Kolom wajib: tanggal, jam_keberangkatan, jumlah_penumpang. Opsional: hari, jenis_hari, stasiun."),
          uiOutput(ns("status"))),
        uiOutput(ns("isu")),
        bslib::card(bslib::card_header("Ringkasan dataset"), tableOutput(ns("ringkasan"))),
        bslib::card(bslib::card_header("Filter dataset"), mod_filter_ui(ns("filter")),
                    downloadButton(ns("unduh"), "Unduh data terfilter (CSV)", class = "btn-sm"))),
      bslib::card(bslib::card_header("Data preview"),
        tableOutput(ns("tipe")), DT::DTOutput(ns("preview"))))
  )
}

mod_data_server <- function(id, state) {
  moduleServer(id, function(input, output, session) {
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

    output$status <- renderUI(div(class = "mt-2", "File: ", strong(state$file %||% "–"), " ", badge_status(state$status)))
    output$isu <- renderUI({
      tagList(if (grepl("simulasi", state$file %||% "")) div(class = "alert alert-warning py-2", "Data contoh ini SIMULASI untuk demo, bukan data penumpang aktual."),
              kotak_isu(state$issues))
    })
    output$ringkasan <- renderTable({
      req(state$info); i <- state$info
      data.frame(Keterangan = c("Jumlah baris (asli)", "Jumlah kolom", "Baris dengan nilai kosong", "Baris duplikat", "Baris valid dipakai"),
                 Nilai = c(i$n_baris, i$n_kolom, i$kosong, i$duplikat, i$valid))
    })
    output$tipe <- renderTable({
      req(state$data)
      d <- data_f()
      data.frame(Kolom = names(d), Tipe = vapply(d, function(x) class(x)[1], ""))
    })
    output$preview <- DT::renderDT({
      req(state$data)
      DT::datatable(data_f(), rownames = FALSE, options = list(pageLength = 10, dom = "ftip"))
    })
    output$unduh <- downloadHandler(
      filename = function() "dataset_aktif.csv",
      content = function(file) utils::write.csv(data_f(), file, row.names = FALSE))
  })
}
