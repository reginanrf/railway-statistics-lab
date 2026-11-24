# ==== mod_filter.R ==================================================
# Modul filter dataset (periode, jenis hari, jam, stasiun).
# Dipakai di menu Data dan Analisis. Mengembalikan reactive data terfilter.

mod_filter_ui <- function(id) {
  ns <- NS(id)
  div(class = "filter-bar",
    dateRangeInput(ns("periode"), "Periode tanggal", start = NULL, end = NULL, language = "id"),
    selectInput(ns("jenis"), "Jenis hari", choices = c("Semua" = "")),
    selectInput(ns("jam"), "Jam keberangkatan", choices = c("Semua" = "")),
    uiOutput(ns("ui_stasiun")),
    actionButton(ns("reset"), "Reset filter", class = "btn-sm btn-outline-primary")
  )
}

mod_filter_server <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    isi_ulang <- function() {
      d <- data(); req(d)
      jam <- sort(unique(d$jam))
      updateDateRangeInput(session, "periode", start = min(d$tanggal), end = max(d$tanggal), min = min(d$tanggal), max = max(d$tanggal))
      updateSelectInput(session, "jenis", choices = c("Semua" = "", sort(unique(d$jenis_hari))), selected = "")
      updateSelectInput(session, "jam", choices = c("Semua" = "", stats::setNames(jam, sprintf("%02d:00", jam))), selected = "")
      updateSelectInput(session, "stasiun", selected = "")
    }
    observeEvent(data(), isi_ulang(), ignoreNULL = TRUE)
    observeEvent(input$reset, isi_ulang())

    output$ui_stasiun <- renderUI({
      d <- data(); req(d)
      st <- sort(unique(d$stasiun[d$stasiun != ""]))
      if (length(st) == 0) return(NULL)
      selectInput(session$ns("stasiun"), "Stasiun", choices = c("Semua" = "", st))
    })

    reactive({
      d <- data(); req(d)
      p <- input$periode
      if (!is.null(p) && !anyNA(p)) d <- d[d$tanggal >= p[1] & d$tanggal <= p[2], ]
      if (nzchar(atau(input$jenis, ""))) d <- d[d$jenis_hari == input$jenis, ]
      if (nzchar(atau(input$jam, ""))) d <- d[d$jam == as.integer(input$jam), ]
      if (nzchar(atau(input$stasiun, ""))) d <- d[d$stasiun == input$stasiun, ]
      d
    })
  })
}
