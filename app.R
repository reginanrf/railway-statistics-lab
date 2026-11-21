# ==== app.R =========================================================
# Titik masuk aplikasi Railway Statistics Lab.
# Semua file di folder R/ dimuat otomatis oleh Shiny (>= 1.5).
# HANYA integrator yang mengubah file ini (lihat docs/PANDUAN.md).

library(shiny)
library(bslib)

tema <- bs_theme(
  version = 5, primary = "#5B4BE8", secondary = "#8A3FD8",
  bg = "#F3F4FB", fg = "#1B1B3A",
  base_font = font_google("Plus Jakarta Sans")
)

ui <- page_fluid(
  theme = tema, title = "Railway Statistics Lab",
  tags$head(tags$link(rel = "stylesheet", href = "custom.css")),
  navset_pill_list(
    id = "menu", widths = c(2, 10), well = FALSE,
    nav_item(div(class = "brand", "Railway Statistics Lab", span("Analisis pola penumpang KA"))),
    nav_panel(title = tagList(icon("house"), "Beranda"), value = "beranda", mod_beranda_ui("beranda")),
    nav_panel(title = tagList(icon("database"), "Data"), value = "data", mod_data_ui("data")),
    nav_panel(title = tagList(icon("flask"), "Analisis"), value = "analisis", mod_analisis_ui("analisis")),
    nav_panel(title = tagList(icon("circle-info"), "Tentang"), value = "tentang", mod_tentang_ui("tentang"))
  )
)

server <- function(input, output, session) {
  # State bersama seluruh modul (kontrak: lihat docs/PANDUAN.md bagian 8)
  state <- reactiveValues(data = NULL, status = "none", info = NULL, issues = list(), file = NULL, dimuat = NULL)
  ke_halaman <- function(halaman) nav_select("menu", halaman, session = session)

  mod_beranda_server("beranda", state, ke_halaman)
  mod_data_server("data", state)
  mod_analisis_server("analisis", state)
  mod_tentang_server("tentang")
}

shinyApp(ui, server)
