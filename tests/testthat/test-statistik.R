# Perhitungan harus sama dengan perhitungan pembanding (manual / Excel).
source(testthat::test_path("../../R/fct_data.R"))
source(testthat::test_path("../../R/fct_statistik.R"))

test_that("statistik deskriptif sesuai pembanding", {
  x <- c(2, 4, 4, 4, 5, 5, 7, 9)   # mean 5, median 4.5, modus 4, var sampel 32/7
  t <- hitung_deskriptif(x)
  nilai <- function(u) t$Nilai[t$Ukuran == u]
  expect_equal(nilai("Mean"), "5")
  expect_equal(nilai("Median"), "4,5")
  expect_equal(nilai("Modus"), "4")
  expect_equal(nilai("Range"), "7")
  expect_equal(nilai("Varians"), "4,57")
})

test_that("validasi dataset mengeluarkan baris bermasalah", {
  raw <- data.frame(
    tanggal = c("2026-11-02", "2026-11-02", "07/11/2026", "2026-11-03", "2026-11-04"),
    jam_keberangkatan = c("07:00", "07:00", "07:00", "08:00", "09:00"),
    jumlah_penumpang = c("150", "150", "90", "-5", ""))
  h <- proses_dataset(raw)
  expect_equal(h$info$kosong, 1)
  expect_equal(h$info$duplikat, 1)
  expect_equal(h$info$valid, 2)
  expect_equal(h$status, "warn")
  expect_equal(h$data$jenis_hari[h$data$tanggal == as.Date("2026-11-07")], "Akhir pekan")
})

test_that("dataset tanpa jumlah_penumpang ditolak", {
  h <- proses_dataset(data.frame(tanggal = "2026-11-02", jam_keberangkatan = "07:00", stasiun = "Bandung"))
  expect_equal(h$status, "bad")
  expect_null(h$data)
})
