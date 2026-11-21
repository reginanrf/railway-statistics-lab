# Panduan Kerja Tim — Railway Statistics Lab (R Shiny + GitHub)

Panduan ini membawa tim dari **membuat repositori** sampai **integrasi kode** dan rilis versi presentasi.

---

## 0. Peran dan pembagian modul

Satu orang menjadi **Integrator** (pemilik repositori, satu-satunya yang mengubah `app.R` dan melakukan merge akhir). Sisanya memegang modul. Contoh untuk 4 orang (sesuaikan):

| Peran | File milik (hanya ia yang mengubah) |
|---|---|
| Integrator / Ketua | `app.R`, `R/utils_ui.R`, `README.md`, `docs/`, review akhir |
| Anggota Data | `R/fct_data.R`, `R/mod_data.R`, `R/mod_filter.R` |
| Anggota Analisis | `R/fct_statistik.R`, `R/fct_grafik.R`, `R/mod_analisis.R`, `tests/` |
| Anggota Beranda/Tentang/UI | `R/mod_beranda.R`, `R/mod_tentang.R`, `www/custom.css` |

**Aturan emas:** satu file = satu pemilik. Ini membuat konflik merge hampir tidak pernah terjadi.

---

## 1. Prasyarat (semua anggota)

1. Instal **R ≥ 4.1** dan **RStudio**.
2. Instal **Git** (`git --version` untuk cek).
3. Punya akun **GitHub**.
4. Atur identitas Git (sekali saja), di terminal RStudio:
   ```bash
   git config --global user.name "Nama Anda"
   git config --global user.email "email@akungithub.com"
   ```
5. Atur autentikasi ke GitHub (pilih satu):
   - HTTPS + Personal Access Token: di R jalankan `install.packages("usethis"); usethis::create_github_token()`, lalu `gitcreds::gitcreds_set()` dan tempel token.
   - atau SSH key (RStudio → Tools → Global Options → Git/SVN → Create SSH Key, lalu tambahkan ke GitHub → Settings → SSH keys).

---

## 2. Membuat repositori (Integrator)

1. GitHub → **New repository**.
2. Nama: `railway-statistics-lab`. Visibility: Private (atau Public sesuai kebutuhan kuliah).
3. Centang **Add a README**; pilih `.gitignore` template **R**; license opsional. Klik **Create repository**.
4. **Undang anggota:** Settings → Collaborators → Add people (beri akses *Write*).
5. **Lindungi branch `main`:** Settings → Branches → Add branch ruleset / protection rule untuk `main`:
   - Require a pull request before merging (minimal 1 approval)
   - Require conversation resolution before merging
   - (opsional) Block force pushes
   Dengan ini tidak ada yang bisa langsung push ke `main`.
6. **Buat label** (Issues → Labels): `modul:data`, `modul:analisis`, `modul:ui`, `bug`, `fitur`.
7. **Buat Project board** (tab Projects) dengan kolom *Todo / Doing / Review / Done*, dan buat issue untuk setiap tugas (lihat bagian 9).

---

## 3. Mengambil repositori ke komputer (semua anggota)

Pilih salah satu:

**RStudio:** File → New Project → Version Control → Git → isi URL repositori → pilih folder → Create Project.

**Terminal:**
```bash
git clone https://github.com/<akun-atau-org>/railway-statistics-lab.git
cd railway-statistics-lab
```
Lalu buka `railway-statistics-lab.Rproj` di RStudio.

---

## 4. Memasukkan struktur awal (Integrator, sekali saja)

1. Ekstrak starter kit (`railway-statistics-lab.zip`) lalu **salin isinya** (bukan folder pembungkusnya) ke folder repositori hasil clone. Timpa `README.md` dan `.gitignore` bawaan GitHub dengan versi starter.
2. Jalankan aplikasi untuk memastikan jalan:
   ```r
   install.packages(c("shiny","bslib","readr","readxl","lubridate","tibble","dplyr","tidyr","DT","ggplot2","plotly","testthat","renv"))
   shiny::runApp()
   ```
   Klik **Muat contoh (simulasi)** lalu coba menu Analisis.
3. Kunci versi paket dengan renv agar semua anggota memakai versi yang sama:
   ```r
   renv::init()        # pilih "restore project from lockfile / use library" sesuai prompt
   renv::snapshot()    # menghasilkan renv.lock
   ```
4. Commit pertama langsung ke `main` (aturan proteksi baru diaktifkan setelah ini, atau Integrator sementara boleh bypass):
   ```bash
   git add .
   git commit -m "chore: struktur awal aplikasi Shiny"
   git push origin main
   ```
5. Beri tahu tim: **`git pull` dulu, lalu jalankan `renv::restore()`**.

> Setiap kali ada yang menambah paket baru: `renv::install("namapaket")` → pakai di kode → `renv::snapshot()` → commit `renv.lock` dalam PR yang sama, dan kabari tim.

---

## 5. Alur kerja harian (semua anggota)

Setiap tugas = **satu branch pendek** → **Pull Request** → review → merge.

```bash
# 1. mulai dari main yang terbaru
git checkout main
git pull origin main
renv::restore()   # (di R) bila renv.lock berubah

# 2. buat branch tugas. Format: tipe/modul-deskripsi-singkat
git checkout -b fitur/data-validasi-duplikat

# 3. kerjakan, jalankan app, lalu commit kecil & sering
git add R/fct_data.R
git commit -m "feat(data): deteksi baris duplikat"

# 4. dorong branch
git push -u origin fitur/data-validasi-duplikat
```
5. Di GitHub klik **Compare & pull request**, isi template, minta review dari teman (dan Integrator).
6. Reviewer menjalankan branch-nya (`git fetch` → `git checkout <branch>` → `shiny::runApp()`), memberi komentar, lalu **Approve**.
7. Integrator/penulis klik **Squash and merge**, hapus branch. Semua anggota `git pull origin main`.

**Konvensi pesan commit:** `tipe(modul): deskripsi`, tipe ∈ `feat`, `fix`, `style`, `docs`, `test`, `chore`. Contoh: `fix(analisis): heatmap tidak urut jam`.

**Jangan:** commit langsung ke `main`, commit data pribadi/besar, commit file `.Rhistory`/`.RData`, mengedit file milik orang lain tanpa koordinasi.

---

## 6. Cara kerja kode (memahami arsitektur)

- **`app.R`** menyusun sidebar (empat menu) dan memanggil modul. Folder `R/` dimuat otomatis oleh Shiny.
- Setiap halaman = **modul Shiny**: `mod_x_ui(id)` + `mod_x_server(id, ...)`.
- **Fungsi murni** (`fct_*.R`) berisi perhitungan tanpa Shiny, sehingga bisa diuji dan dipakai ulang.
- **State bersama** dikelola satu `reactiveValues` bernama `state` yang dibuat di `app.R` dan dioper ke modul.

---

## 7. Menambahkan atau mengubah fitur

### Menambah ukuran statistik (Anggota Analisis)
Edit `hitung_deskriptif()` di `R/fct_statistik.R` (tambah ukuran di vektor `Ukuran` dan `Nilai`), tambahkan test di `tests/testthat/test-statistik.R`.

### Menambah jenis grafik
Tambah fungsi `grafik_xxx()` di `R/fct_grafik.R` (kembalikan objek `plotly`), lalu panggil dari `hitung_analisis_*()` di `R/mod_analisis.R` sebagai `plot1` atau `plot2`.

### Menambah halaman/modul baru (mis. Riwayat Analisis)
1. Buat `R/mod_riwayat.R` dengan `mod_riwayat_ui(id)` dan `mod_riwayat_server(id, state)`.
2. **Integrator** menambahkan satu `nav_panel(...)` di `app.R` dan satu baris `mod_riwayat_server("riwayat", state)` di `server`.

### Aturan data (ditegakkan di seluruh kode)
- Seluruh angka dan grafik berasal dari `state$data` (dataset unggahan). Tanpa data → tampilkan empty state, **jangan angka dummy**.
- Jumlah perjalanan/frekuensi jadwal **bukan** jumlah penumpang.
- Interpretasi otomatis hanya mendeskripsikan hasil, **tanpa klaim sebab-akibat**.
- Perbandingan kelompok memakai rata-rata per pengamatan; bila memakai total, tampilkan jumlah pengamatan/hari.

---

## 8. Kontrak antarmodul (`state`)

Semua modul membaca/menulis hanya field berikut. Mengubah kontrak ini = harus disetujui Integrator dan diumumkan ke tim.

| Field | Isi | Ditulis oleh |
|---|---|---|
| `state$data` | tibble valid: `tanggal` (Date), `jam` (int 0–23), `jumlah_penumpang` (num), `hari`, `jenis_hari`, `stasiun` (`""` bila tidak ada); `NULL` bila belum ada | modul Data |
| `state$status` | `"none"` \| `"ok"` \| `"warn"` \| `"bad"` | modul Data |
| `state$info` | list: `n_baris`, `n_kolom`, `kosong`, `duplikat`, `valid` | modul Data |
| `state$issues` | list isu validasi (`tipe`, `pesan`) | modul Data |
| `state$file`, `state$dimuat` | nama file dan waktu dimuat | modul Data |

Modul lain (Beranda, Analisis) **hanya membaca** `state`. Navigasi antarhalaman memakai fungsi `ke_halaman("data")` yang dioper dari `app.R`.

---

## 9. Pembagian tugas awal (dijadikan issue)

**Prioritas 1 (wajib berfungsi untuk demo):**
- Data: unggah CSV/Excel, preview, validasi dasar → `modul:data`
- Analisis: statistik deskriptif, distribusi, bar chart, heatmap → `modul:analisis`
- Beranda & Tentang: isi nama anggota, sumber dataset, rumus → `modul:ui`

**Prioritas 2:** filter, pemeriksaan duplikat, interpretasi otomatis, ekspor CSV, line chart, boxplot, perbandingan deskriptif.

**Prioritas 3:** riwayat analisis, ekspor PDF, analisis inferensial. Kerjakan setelah Prioritas 1 stabil.

Starter kit ini sudah berisi implementasi dasar Prioritas 1–2; tugas tim adalah **memverifikasi, menyempurnakan, dan menguji dengan dataset nyata**.

---

## 10. Integrasi kode (Integrator)

1. Pastikan semua PR modul sudah **merge ke `main`** satu per satu (urutan disarankan: Data → Analisis → Beranda/Tentang), tiap merge diikuti `git pull` dan uji cepat.
2. Jalankan pemeriksaan sebelum merge PR terakhir:
   ```r
   renv::status()                            # lockfile sinkron?
   testthat::test_dir("tests/testthat")      # semua test lulus?
   shiny::runApp()                           # jalankan skenario demo
   ```
3. **Skenario demo** (uji sebagai checklist): Beranda (empty state) → Data → unggah file → preview + validasi → Analisis → Statistik Deskriptif → Jalankan → Distribusi → heatmap/bar chart → Perbandingan → unduh hasil.
4. **Kriteria siap presentasi:** dataset contoh terbaca tanpa error; validasi menampilkan pesan yang jelas; hasil sama dengan perhitungan pembanding (Excel/manual); grafik mengikuti filter dan agregasi; interpretasi tidak menyesatkan.
5. Beri tag rilis:
   ```bash
   git checkout main && git pull
   git tag -a v0.1 -m "Versi presentasi awal"
   git push origin v0.1
   ```

### Menyelesaikan konflik merge
Bila GitHub menampilkan *conflict*:
```bash
git checkout fitur/nama-branch
git fetch origin
git merge origin/main        # Git menandai konflik di file
# buka file, cari <<<<<<< ======= >>>>>>>, pilih/gabungkan isi yang benar
git add <file>
git commit
git push
```
Bila ragu, jangan hapus kode orang lain — tanyakan pemilik file.

---

## 11. Menjalankan test

```r
testthat::test_dir("tests/testthat")
```
Test perhitungan memakai data kecil dengan jawaban yang bisa dihitung manual. Tambahkan test setiap mengubah rumus.

## 12. Pemecahan masalah

| Masalah | Solusi |
|---|---|
| `could not find function "%||%"` / `|>` error | Perbarui ke R ≥ 4.1 |
| Paket tidak ditemukan | `renv::restore()` setelah `git pull` |
| Font tidak muncul | Butuh internet saat pertama kali (Google Fonts); aplikasi tetap jalan dengan font default |
| `git push` ditolak | Bukan branch `main`? Dorong branch fitur, lalu buat Pull Request |
| Excel tanggal berantakan | Pastikan kolom `tanggal` bertipe tanggal/teks `yyyy-mm-dd` atau `dd/mm/yyyy`; jam `HH:MM` |
| CSV pemisah `;` | Sudah dideteksi otomatis; bila masih gagal simpan ulang sebagai CSV UTF-8 |
| Pull Request penuh konflik | Pecah PR lebih kecil; pastikan satu file hanya dikerjakan satu orang |
