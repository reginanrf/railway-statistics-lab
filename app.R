# ==== app.R =========================================================
# Titik masuk aplikasi Railway Statistics Lab.
# Semua file di folder R/ dimuat otomatis oleh Shiny (>= 1.5).
# HANYA integrator yang mengubah file ini (lihat docs/PANDUAN.md).

library(shiny)
library(bslib)

tema <- bs_theme(
  version = 5, primary = "#5B4BE8", secondary = "#8A3FD8",
  bg = "#F3F4FB", fg = "#1B1B3A",
  base_font = font_google("Plus Jakarta Sans"),
  "font-size-base" = "0.875rem"
)

menu_nav <- list(
  list(id = "beranda", label = "Beranda", ikon = "Beranda"),
  list(id = "data", label = "Data", ikon = "Data"),
  list(id = "analisis", label = "Analisis", ikon = "Analisis"),
  list(id = "tentang", label = "Tentang", ikon = "Tentang")
)

ui <- page_fluid(
  theme = tema, title = "Railway Statistics Lab",
  tags$head(
    tags$link(rel = "stylesheet", href = "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@500&display=swap"),
    tags$style(HTML(css_rsl)),
    tags$script(HTML(js_rsl))),
  sprite_ikon(),
  div(class = "rsl-shell",
      tags$nav(class = "rsl-nav",
               div(class = "brand", div(class = "logo", ikon("trn")),
                   tags$h1("Railway Statistics Lab", tags$small("Analisis pola penumpang KA"))),
               div(class = "nav-links",
                   lapply(menu_nav, function(m)
                     tags$button(type = "button", class = paste("nav-btn", if (m$id == "beranda") "on"),
                                 `data-page` = m$id, ikon(m$ikon), m$label)))),
      tags$main(class = "rsl-main",
                navset_hidden(id = "menu",
                              nav_panel_hidden(value = "beranda", mod_beranda_ui("beranda")),
                              nav_panel_hidden(value = "data", mod_data_ui("data")),
                              nav_panel_hidden(value = "analisis", mod_analisis_ui("analisis")),
                              nav_panel_hidden(value = "tentang", mod_tentang_ui("tentang"))))
  )
)

server <- function(input, output, session) {
  # State bersama seluruh modul (kontrak: lihat docs/PANDUAN.md bagian 8)
  state <- reactiveValues(data = NULL, status = "none", info = NULL, issues = list(), file = NULL, dimuat = NULL)
  ke_halaman <- function(halaman, jenis = NULL) {
    if (!is.null(jenis)) updateRadioButtons(session, "analisis-jenis", selected = jenis)
    nav_select("menu", halaman, session = session)
  }
  observeEvent(input$nav_pilih, nav_select("menu", input$nav_pilih, session = session))

  mod_beranda_server("beranda", state, ke_halaman)
  mod_data_server("data", state)
  mod_analisis_server("analisis", state)
  mod_tentang_server("tentang")
}

shinyApp(ui, server)
