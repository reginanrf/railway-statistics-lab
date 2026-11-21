[pull_request_template.md](https://github.com/user-attachments/files/35212699/pull_request_template.md)
## Ringkasan
<!-- Apa yang diubah dan kenapa? Tautkan issue: Closes #nomor -->

## Jenis perubahan
- [ ] Fitur baru
- [ ] Perbaikan bug
- [ ] Tampilan (UI)
- [ ] Dokumentasi / test

## Checklist sebelum minta review
- [ ] Aplikasi berjalan: `shiny::runApp()` tanpa error
- [ ] Hanya mengubah file milik modul saya (atau sudah koordinasi)
- [ ] Menambah/memperbarui test bila mengubah perhitungan (`testthat::test_dir("tests/testthat")`)
- [ ] Tidak ada data pribadi/besar yang ikut ter-commit
- [ ] Angka & interpretasi hanya berasal dari dataset aktif (tidak ada angka dummy)

## Cara menguji
<!-- Langkah singkat agar reviewer bisa mencoba, mis. muat contoh -> Analisis -> Distribusi -->
