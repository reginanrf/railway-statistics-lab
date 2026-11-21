# ==== utils_ui.R ====================================================
# Komponen UI kecil yang dipakai bersama banyak modul.
# Kelas CSS mengikuti Railway_Statistics_Lab_v3.html (lihat www/custom.css).

atau <- function(a, b) if (is.null(a) || length(a) == 0) b else a
`%||%` <- function(a, b) if (is.null(a)) b else a

# Sprite ikon SVG (dipakai sidebar, pintasan, logo)
sprite_ikon <- function() {
  HTML('<svg width="0" height="0" style="position:absolute"><defs>
<symbol id="i-Beranda" viewBox="0 0 24 24"><path d="M3 11l9-7 9 7v9a1 1 0 01-1 1h-5v-6H9v6H4a1 1 0 01-1-1z"/></symbol>
<symbol id="i-Data" viewBox="0 0 24 24"><ellipse cx="12" cy="6" rx="8" ry="3"/><path d="M4 6v12c0 1.7 3.6 3 8 3s8-1.3 8-3V6M4 12c0 1.7 3.6 3 8 3s8-1.3 8-3"/></symbol>
<symbol id="i-Analisis" viewBox="0 0 24 24"><path d="M9 3h6M10 3v6L4.5 19a1.5 1.5 0 001.3 2h12.4a1.5 1.5 0 001.3-2L14 9V3M7.5 15h9"/></symbol>
<symbol id="i-Tentang" viewBox="0 0 24 24"><circle cx="12" cy="12" r="9"/><path d="M12 11v6M12 7.5v.01"/></symbol>
<symbol id="i-Stat" viewBox="0 0 24 24"><path d="M4 20V10M10 20V4M16 20v-8M22 20H2"/></symbol>
<symbol id="i-Dist" viewBox="0 0 24 24"><path d="M2 20h20M3 20c4 0 5-15 9-15s5 15 9 15"/></symbol>
<symbol id="i-Cmp" viewBox="0 0 24 24"><path d="M4 8h14l-4-4M20 16H6l4 4"/></symbol>
<symbol id="i-trn" viewBox="0 0 24 24"><rect x="5" y="3" width="14" height="14" rx="4"/><path d="M5 11h14M9 20l-2 2M15 20l2 2M9 14.5v.01M15 14.5v.01"/></symbol>
</defs></svg>')
}
ikon <- function(id) HTML(sprintf('<svg><use href="#i-%s"/></svg>', id))

# Pindah halaman dari tombol HTML biasa (ditangkap di app.R sebagai input$nav_pilih)
js_ke <- function(halaman) sprintf("Shiny.setInputValue('nav_pilih','%s',{priority:'event'})", halaman)

# Header halaman (pita putih di atas konten), sama di semua halaman:
#   Judul  [lencana]
#   Subjudul
page_header <- function(judul, sub = NULL, lencana = NULL) {
  div(class = "ph",
      div(class = "ph-in",
          div(class = "ph-row", h2(judul), lencana),
          if (!is.null(sub)) p(class = "ph-sub", sub)))
}

# Pembungkus isi halaman: memberi padding kiri-kanan agar konten tidak menempel ke sidebar/tepi layar.
# Header (page_header) berada di LUAR pembungkus ini supaya tetap selebar layar. top = TRUE bila halaman tanpa header.
page_body <- function(..., top = FALSE) div(class = paste("pg", if (top) "pg-top"), ...)

# Kartu statistik dengan garis aksen di kiri
kartu_stat <- function(label, nilai, sub = NULL, hi = FALSE, kecil = FALSE) {
  div(class = "card st", span(label),
      tags$b(class = paste(c(if (hi) "hi", if (kecil) "per"), collapse = " "), nilai),
      if (!is.null(sub)) span(sub))
}

badge_status <- function(status) {
  switch(status %||% "none",
         none = span(class = "badge mu", "Belum ada data"),
         ok   = span(class = "badge ok", "Data berhasil dimuat"),
         warn = span(class = "badge wr", "Data perlu diperiksa"),
         bad  = span(class = "badge er", "Data tidak dapat dipakai"))
}

kotak_isu <- function(isu) {
  lapply(isu, function(i) div(class = paste("msg", if (i$tipe == "error") "er" else "wr"), i$pesan))
}

kartu_kosong <- function(...) {
  div(class = "card empty", h3("Belum ada dataset"),
      "Unggah file CSV/Excel di menu Data. Angka statistik tidak ditampilkan sebelum dataset dimuat.",
      tags$br(), tags$br(),
      tags$button(type = "button", class = "btn", onclick = js_ke("data"), "Buka Data"), ...)
}
