# ==== fct_statistik.R ===============================================
# Semua perhitungan statistik deskriptif. Fungsi murni (tanpa Shiny)
# agar mudah diuji di tests/testthat.
# Penanggung jawab: Anggota Analisis

JAM_SIBUK <- c(6:9, 16:19)   # aturan eksplisit: 06.00-09.59 dan 16.00-19.59

hitung_modus <- function(x) {
  tb <- table(x)
  if (max(tb) == 1) return("Tidak ada modus")
  m <- as.numeric(names(tb)[tb == max(tb)])
  paste0(paste(head(m, 3), collapse = ", "), if (length(m) > 3) "…" else "")
}

# Tabel statistik deskriptif untuk vektor numerik x
hitung_deskriptif <- function(x) {
  v <- if (length(x) > 1) stats::var(x) else NA_real_
  q <- stats::quantile(x, c(.1, .25, .75, .9), names = FALSE, type = 7)
  tibble::tibble(
    Ukuran = c("N", "Total", "Mean", "Median", "Modus", "Minimum", "Maksimum", "Range",
               "Varians", "Standar deviasi", "Q1", "Q3", "P10", "P90"),
    Nilai = c(fmt_id(length(x), 0), fmt_id(sum(x)), fmt_id(mean(x)), fmt_id(stats::median(x)), hitung_modus(x),
              fmt_id(min(x)), fmt_id(max(x)), fmt_id(max(x) - min(x)), fmt_id(v), fmt_id(sqrt(v)),
              fmt_id(q[2]), fmt_id(q[3]), fmt_id(q[1]), fmt_id(q[4]))
  )
}

# Agregasi menurut satu/dua kunci. ukuran: "total" | "mean" | "persen"
agregasi <- function(df, kunci, ukuran = c("mean", "total", "persen")) {
  ukuran <- match.arg(ukuran)
  tot <- sum(df$jumlah_penumpang)
  out <- df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(kunci))) |>
    dplyr::summarise(pengamatan = dplyr::n(), hari_diamati = dplyr::n_distinct(tanggal),
                     total = sum(jumlah_penumpang), rata_rata = mean(jumlah_penumpang), .groups = "drop")
  out$persen <- out$total / tot * 100
  out$nilai <- switch(ukuran, total = out$total, mean = out$rata_rata, persen = out$persen)
  out
}

# Perbandingan deskriptif dua kelompok. kelompok: "kerja_akhir_pekan" | "kerja_libur" | "jam_sibuk"
siapkan_kelompok <- function(df, kelompok) {
  if (kelompok == "kerja_akhir_pekan") {
    df <- df[df$jenis_hari %in% c("Hari kerja", "Akhir pekan"), ]; df$kelompok <- df$jenis_hari
  } else if (kelompok == "kerja_libur") {
    df <- df[df$jenis_hari %in% c("Hari kerja", "Hari libur"), ]; df$kelompok <- df$jenis_hari
  } else {
    df$kelompok <- ifelse(df$jam %in% JAM_SIBUK, "Jam sibuk", "Jam lainnya")
  }
  df
}

bandingkan <- function(df) {
  g <- unique(df$kelompok)
  if (length(g) != 2) return(NULL)
  g <- sort(g)
  ukur <- function(x) c(Pengamatan = length(x), Total = sum(x), `Rata-rata` = mean(x), Median = stats::median(x),
                        Minimum = min(x), Maksimum = max(x), `Std. deviasi` = stats::sd(x))
  a <- ukur(df$jumlah_penumpang[df$kelompok == g[1]]); b <- ukur(df$jumlah_penumpang[df$kelompok == g[2]])
  tab <- tibble::tibble(Ukuran = names(a), A = unname(a), B = unname(b), Selisih = unname(a - b),
                        `Persen beda (thd B)` = ifelse(b == 0, NA, unname((a - b) / b * 100)))
  names(tab)[2:3] <- g
  list(tabel = tab, kelompok = g)
}

# ---- Interpretasi otomatis (deskripsi hasil, BUKAN klaim sebab-akibat) ----
interpretasi_deskriptif <- function(x) {
  m <- mean(x); md <- stats::median(x)
  c(sprintf("Dari %s pengamatan, rata-rata jumlah penumpang %s dan median %s (rentang %s–%s).",
            fmt_id(length(x), 0), fmt_id(m), fmt_id(md), fmt_id(min(x)), fmt_id(max(x))),
    if (m > md) "Rata-rata lebih besar daripada median: sebaran memiliki nilai besar yang menarik rata-rata ke atas."
    else if (m < md) "Rata-rata lebih kecil daripada median: sebaran memiliki nilai kecil yang menarik rata-rata ke bawah."
    else "Rata-rata sama dengan median.")
}

interpretasi_agregasi <- function(tab, kolom_label, ukuran, awalan = "") {
  i <- which.max(tab$nilai)
  satuan <- c(total = "total penumpang", mean = "rata-rata per pengamatan", persen = "% dari total")[[ukuran]]
  sprintf("Nilai tertinggi (%s) tercatat pada %s%s: %s%s.", satuan, awalan, tab[[kolom_label]][i],
          fmt_id(tab$nilai[i]), if (ukuran == "persen") "%" else "")
}

interpretasi_perbandingan <- function(cmp, ukuran = "Rata-rata") {
  tb <- cmp$tabel; g <- cmp$kelompok
  r <- tb[tb$Ukuran == ukuran, ]; a <- r[[g[1]]]; b <- r[[g[2]]]
  if (a == b) return(sprintf("Nilai %s kedua kelompok sama (%s).", tolower(ukuran), fmt_id(a)))
  hi <- if (a > b) g[1] else g[2]; lo <- if (a > b) g[2] else g[1]
  sprintf("%s kelompok %s (%s) lebih tinggi dibanding %s (%s), selisih %s.",
          ukuran, tolower(hi), fmt_id(max(a, b)), tolower(lo), fmt_id(min(a, b)), fmt_id(abs(a - b)))
}
