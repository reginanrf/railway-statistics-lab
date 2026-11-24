# ==== fct_data.R ====================================================
# Fungsi membaca, memvalidasi, dan mentransformasi dataset.
# Penanggung jawab: Anggota Data (lihat docs/PANDUAN.md)
# Unit pengamatan: 1 baris = jumlah penumpang pada 1 tanggal + 1 jam
# keberangkatan (+ 1 stasiun jika kolom stasiun tersedia).

KOLOM_WAJIB <- c("tanggal", "jam_keberangkatan", "jumlah_penumpang")
HARI_ID     <- c("Minggu", "Senin", "Selasa", "Rabu", "Kamis", "Jumat", "Sabtu")

# Berkas bawaan hasil alokasi (bukan pencacahan). Dipakai untuk menandai label di UI
# agar tidak tampil sebagai "Data Aktual". Rinciannya dijelaskan di menu Tentang.
BERKAS_ALOKASI <- c("jabodetabek_2025.csv", "jabodetabek_2025_agregat.csv")

# Mengembalikan "simulasi" | "alokasi" | "aktual" berdasarkan nama berkas
jenis_sumber <- function(nama) {
  nama <- if (is.null(nama) || length(nama) == 0 || is.na(nama[1])) "" else as.character(nama[1])
  if (grepl("simulasi", nama)) {
    "simulasi"
  } else if (nama %in% BERKAS_ALOKASI) {
    "alokasi"
  } else {
    "aktual"
  }
}

buat_isu <- function(tipe, pesan) list(tipe = tipe, pesan = pesan)

# Format angka gaya Indonesia (1.234,56)
fmt_id <- function(x, digit = 2) {
  format(round(x, digit), big.mark = ".", decimal.mark = ",", nsmall = 0, scientific = FALSE, trim = TRUE)
}

parse_tanggal <- function(x) {
  if (inherits(x, "Date"))  return(x)
  if (inherits(x, "POSIXt")) return(as.Date(x))
  if (is.numeric(x)) return(as.Date(x, origin = "1899-12-30"))
  x <- trimws(as.character(x))
  # Jalur cepat untuk format yyyy-mm-dd (penting untuk berkas ratusan ribu baris)
  out <- suppressWarnings(as.Date(x, format = "%Y-%m-%d"))
  sisa <- is.na(out)
  if (any(sisa)) {
    out[sisa] <- suppressWarnings(as.Date(lubridate::parse_date_time(x[sisa], orders = c("Ymd", "dmY"), quiet = TRUE)))
  }
  num <- suppressWarnings(as.numeric(x))
  idx <- is.na(out) & !is.na(num) & num > 20000   # serial tanggal Excel yang terbaca sebagai teks
  out[idx] <- as.Date(num[idx], origin = "1899-12-30")
  out
}

parse_jam <- function(x) {
  if (inherits(x, "POSIXt")) return(as.integer(format(x, "%H")))
  if (is.numeric(x)) {
    h <- ifelse(x > 0 & x < 1, floor(x * 24 + 1e-6), ifelse(x == floor(x), x, NA))
  } else {
    x <- trimws(as.character(x))
    h <- suppressWarnings(as.integer(sub("^(\\d{1,2})([:.]\\d{2}.*)?$", "\\1", x)))
  }
  h <- as.integer(h)
  h[!is.na(h) & (h < 0 | h > 23)] <- NA_integer_
  h
}

parse_angka <- function(x) {
  if (is.numeric(x)) return(as.numeric(x))
  suppressWarnings(as.numeric(gsub(",", ".", trimws(as.character(x)), fixed = TRUE)))
}

# Membaca file CSV / Excel menjadi data frame mentah
baca_berkas <- function(path, nama) {
  ext <- tolower(tools::file_ext(nama))
  if (ext == "csv") {
    raw <- readr::read_csv(path, col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE)
    if (ncol(raw) == 1) {  # CSV berpemisah titik koma
      raw <- readr::read_delim(path, delim = ";", col_types = readr::cols(.default = readr::col_character()), show_col_types = FALSE)
    }
    raw
  } else if (ext %in% c("xlsx", "xls")) {
    readxl::read_excel(path)
  } else {
    stop("Format file tidak didukung. Gunakan .csv, .xlsx, atau .xls.")
  }
}

# Validasi + transformasi. Mengembalikan list(data, status, info, issues)
# status: "ok" | "warn" | "bad"
proses_dataset <- function(raw) {
  names(raw) <- gsub("\\s+", "_", tolower(trimws(names(raw))))
  info <- list(n_baris = nrow(raw), n_kolom = ncol(raw), kosong = 0L, duplikat = 0L, valid = 0L)

  hilang <- setdiff(KOLOM_WAJIB, names(raw))
  if (length(hilang) > 0) {
    return(list(data = NULL, status = "bad", info = info, issues = list(buat_isu("error",
                                                                                 paste0("Kolom wajib tidak ditemukan: ", paste(hilang, collapse = ", "),
                                                                                        ". Dataset yang hanya berisi jadwal/rute/ID kereta tanpa jumlah penumpang aktual tidak dapat dipakai.")))))
  }

  kosong <- function(x) is.na(x) | trimws(as.character(x)) == ""
  idx_kosong <- Reduce(`|`, lapply(raw[KOLOM_WAJIB], kosong))
  info$kosong <- sum(idx_kosong)
  d <- raw[!idx_kosong, , drop = FALSE]

  tanggal <- parse_tanggal(d$tanggal)
  jam     <- parse_jam(d$jam_keberangkatan)
  n       <- parse_angka(d$jumlah_penumpang)
  idx_fmt <- is.na(tanggal) | is.na(jam)
  idx_num <- !idx_fmt & is.na(n)
  idx_neg <- !idx_fmt & !is.na(n) & n < 0
  ok <- !(idx_fmt | idx_num | idx_neg)

  stasiun <- if ("stasiun" %in% names(d)) trimws(as.character(d$stasiun)) else rep("", nrow(d))
  stasiun[is.na(stasiun)] <- ""
  jenis <- if ("jenis_hari" %in% names(d)) trimws(as.character(d$jenis_hari)) else rep("", nrow(d))
  jenis[is.na(jenis)] <- ""
  wday <- as.POSIXlt(tanggal)$wday

  out <- tibble::tibble(
    tanggal = tanggal, jam = jam, jumlah_penumpang = n,
    hari = HARI_ID[wday + 1],
    jenis_hari = ifelse(jenis != "", paste0(toupper(substr(jenis, 1, 1)), tolower(substring(jenis, 2))),
                        ifelse(wday %in% c(0, 6), "Akhir pekan", "Hari kerja")),
    stasiun = stasiun
  )[ok, ]

  dup <- duplicated(out[c("tanggal", "jam", "stasiun")])
  info$duplikat <- sum(dup)
  out <- out[!dup, ]
  out <- out[order(out$tanggal, out$jam, out$stasiun), ]
  info$valid <- nrow(out)

  isu <- list()
  if (info$kosong > 0)  isu <- c(isu, list(buat_isu("warning", paste0(info$kosong, " baris punya nilai kosong pada kolom wajib dan dikeluarkan."))))
  if (sum(idx_fmt) > 0) isu <- c(isu, list(buat_isu("warning", paste0(sum(idx_fmt), " baris berformat tanggal/jam tidak dikenali (didukung: yyyy-mm-dd, dd/mm/yyyy, HH:MM) dan dikeluarkan."))))
  if (sum(idx_num) > 0) isu <- c(isu, list(buat_isu("warning", paste0(sum(idx_num), " baris jumlah_penumpang bukan angka dan dikeluarkan."))))
  if (sum(idx_neg) > 0) isu <- c(isu, list(buat_isu("warning", paste0(sum(idx_neg), " baris jumlah penumpang negatif dikeluarkan."))))
  if (info$duplikat > 0) isu <- c(isu, list(buat_isu("warning", paste0(info$duplikat, " baris duplikat (tanggal, jam, stasiun sama) dikeluarkan."))))
  if (nrow(out) == 0) isu <- c(isu, list(buat_isu("error", "Tidak ada baris valid yang tersisa.")))

  status <- if (nrow(out) == 0) "bad" else if (length(isu) > 0) "warn" else "ok"
  list(data = if (nrow(out) > 0) out else NULL, status = status, info = info, issues = isu)
}

# Pembantu: simpan hasil proses ke reactiveValues `state`
muat_ke_state <- function(state, hasil, nama) {
  state$data <- hasil$data
  state$status <- hasil$status
  state$info <- hasil$info
  state$issues <- hasil$issues
  state$file <- nama
  state$dimuat <- Sys.time()
}

# Pembantu: baca berkas dari folder data/ (bukan unggahan, jadi tidak kena batas ukuran unggah)
muat_berkas_bawaan <- function(state, path) {
  nama <- basename(path)
  hasil <- tryCatch(proses_dataset(baca_berkas(path, nama)),
                    error = function(e) list(data = NULL, status = "bad", info = NULL,
                                             issues = list(buat_isu("error", paste("Gagal membaca file:", conditionMessage(e))))))
  muat_ke_state(state, hasil, nama)
}
