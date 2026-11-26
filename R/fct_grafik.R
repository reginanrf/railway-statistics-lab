# ==== fct_grafik.R ==================================================
# Fungsi pembuat grafik (ggplot2 -> plotly). Palet mengikuti moodboard.
# Penanggung jawab: Anggota Analisis / UI

WARNA_UTAMA <- "#5B4BE8"
WARNA_AKSEN <- "#F28A2E"

tema_rsl <- function() {
  ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(panel.grid.minor = ggplot2::element_blank(),
                   panel.grid.major.x = ggplot2::element_blank(),
                   panel.grid.major.y = ggplot2::element_line(color = "#E3E5F4"),
                   plot.background = ggplot2::element_rect(fill = "transparent", color = NA),
                   panel.background = ggplot2::element_rect(fill = "transparent", color = NA),
                   axis.text = ggplot2::element_text(color = "#6A6B8A"),
                   axis.title = ggplot2::element_text(color = "#6A6B8A"),
                   plot.title = ggplot2::element_text(face = "bold", color = "#1B1B3A"))
}

# Rapikan objek plotly: font sama dengan aplikasi, latar transparan, tanpa toolbar
rapikan_plotly <- function(p) {
  p |>
    plotly::layout(font = list(family = "Plus Jakarta Sans, system-ui, sans-serif"),
                   paper_bgcolor = "rgba(0,0,0,0)", plot_bgcolor = "rgba(0,0,0,0)",
                   hoverlabel = list(font = list(family = "Plus Jakarta Sans, system-ui, sans-serif"))) |>
    plotly::config(displayModeBar = FALSE)
}

grafik_bar <- function(tab, x, judul, xlab, ylab, persen = FALSE) {
  tab$.x <- factor(tab[[x]], levels = unique(tab[[x]]))
  tab$.hi <- tab$nilai == max(tab$nilai)
  tab$.tip <- paste0(tab$.x, ": ", fmt_id(tab$nilai), if (persen) "%" else "")
  p <- ggplot2::ggplot(tab, ggplot2::aes(.x, nilai, fill = .hi, text = .tip)) +
    ggplot2::geom_col(width = .7) +
    ggplot2::scale_fill_manual(values = c(`TRUE` = WARNA_AKSEN, `FALSE` = WARNA_UTAMA), guide = "none") +
    ggplot2::labs(title = judul, x = xlab, y = ylab) + tema_rsl()
  rapikan_plotly(plotly::ggplotly(p, tooltip = "text"))
}

grafik_heatmap <- function(tab, judul, ukuran_label) {
  tab$jam_lbl <- sprintf("%02d:00", tab$jam)
  tab$.tip <- paste0(tab$jam_lbl, " · ", tab$jenis_hari, ": ", fmt_id(tab$nilai))
  p <- ggplot2::ggplot(tab, ggplot2::aes(jenis_hari, jam_lbl, fill = nilai, text = .tip)) +
    ggplot2::geom_tile(color = "white") +
    ggplot2::geom_text(ggplot2::aes(label = fmt_id(nilai, 1)), size = 3) +
    ggplot2::scale_fill_gradient(low = "#EEF0FF", high = WARNA_UTAMA, name = ukuran_label) +
    ggplot2::scale_y_discrete(limits = rev) +
    ggplot2::labs(title = judul, x = "Jenis hari", y = "Jam keberangkatan") + tema_rsl()
  rapikan_plotly(plotly::ggplotly(p, tooltip = "text"))
}

grafik_boxplot <- function(df, judul) {
  p <- ggplot2::ggplot(df, ggplot2::aes(kelompok, jumlah_penumpang)) +
    ggplot2::geom_boxplot(fill = "#EEF0FF", color = WARNA_UTAMA) +
    ggplot2::labs(title = judul, x = "Kelompok", y = "Jumlah penumpang") + tema_rsl()
  rapikan_plotly(plotly::ggplotly(p))
}

grafik_histogram <- function(df, judul) {
  p <- ggplot2::ggplot(df, ggplot2::aes(jumlah_penumpang)) +
    ggplot2::geom_histogram(bins = 8, fill = WARNA_UTAMA, color = "white") +
    ggplot2::labs(title = judul, x = "Jumlah penumpang", y = "Frekuensi pengamatan") + tema_rsl()
  rapikan_plotly(plotly::ggplotly(p))
}

# Grafik rata-rata jumlah penumpang per pengamatan untuk setiap tanggal.
# Satu tanggal harus menghasilkan tepat satu nilai rata-rata.
grafik_garis <- function(df, judul) {
  # Pastikan kolom tanggal benar-benar bertipe Date dan tidak menyimpan komponen jam.
  tanggal_harian <- as.Date(df$tanggal)

  # Agregasi: seluruh pengamatan pada tanggal yang sama diringkas menjadi
  # satu rata-rata harian. Jumlah pengamatan disimpan untuk tooltip.
  d <- tibble::tibble(
    tanggal = tanggal_harian,
    jumlah_penumpang = as.numeric(df$jumlah_penumpang)
  ) |>
    dplyr::filter(!is.na(tanggal), is.finite(jumlah_penumpang)) |>
    dplyr::group_by(tanggal) |>
    dplyr::summarise(
      rata = mean(jumlah_penumpang),
      n_pengamatan = dplyr::n(),
      .groups = "drop"
    ) |>
    dplyr::arrange(tanggal)

  # Tangani kondisi tidak ada data valid.
  if (nrow(d) == 0) {
    p <- ggplot2::ggplot() +
      ggplot2::labs(
        title = judul,
        x = "Tanggal",
        y = "Rata-rata jumlah penumpang per pengamatan",
        subtitle = "Tidak ada data valid untuk ditampilkan"
      ) +
      tema_rsl()
    return(rapikan_plotly(plotly::ggplotly(p)))
  }

  # Tooltip menampilkan nilai rata-rata dan banyaknya catatan pada tanggal itu.
  d$.tip <- paste0(
    "Tanggal: ", format(d$tanggal, "%d-%m-%Y"),
    "<br>Rata-rata: ", fmt_id(d$rata),
    "<br>Jumlah pengamatan: ", fmt_id(d$n_pengamatan, 0)
  )

  p <- ggplot2::ggplot(
    d,
    ggplot2::aes(
      x = tanggal,
      y = rata,
      group = 1,
      text = .tip
    )
  ) +
    ggplot2::geom_line(color = WARNA_UTAMA, linewidth = 0.7, na.rm = TRUE) +
    ggplot2::geom_point(color = WARNA_UTAMA, size = 1.5, na.rm = TRUE) +
    ggplot2::labs(
      title = judul,
      x = "Tanggal",
      y = "Rata-rata jumlah penumpang per pengamatan"
    ) +
    tema_rsl()

  rapikan_plotly(plotly::ggplotly(p, tooltip = "text"))
}
