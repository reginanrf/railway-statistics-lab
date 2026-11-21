# ==== utils_ui.R ====================================================
# Komponen UI kecil yang dipakai bersama banyak modul.

atau <- function(a, b) if (is.null(a) || length(a) == 0) b else a

badge_status <- function(status) {
  switch(status %||% "none",
    none = span(class = "badge rounded-pill text-bg-secondary", "Belum ada data"),
    ok   = span(class = "badge rounded-pill text-bg-success", "Data berhasil dimuat"),
    warn = span(class = "badge rounded-pill text-bg-warning", "Data perlu diperiksa"),
    bad  = span(class = "badge rounded-pill text-bg-danger", "Data tidak dapat dipakai"))
}
`%||%` <- function(a, b) if (is.null(a)) b else a

kotak_isu <- function(isu) {
  lapply(isu, function(i) div(class = paste("alert", if (i$tipe == "error") "alert-danger" else "alert-warning", "py-2"), i$pesan))
}

kartu_kosong <- function(...) {
  div(class = "empty-state", icon("train"), h4("Belum ada dataset"),
      p("Unggah file CSV/Excel di menu Data. Angka statistik tidak ditampilkan sebelum dataset dimuat."), ...)
}
