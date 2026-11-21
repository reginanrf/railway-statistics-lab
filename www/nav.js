// Navigasi sidebar: kirim pilihan ke server, tandai menu aktif, gulir ke atas.
(function () {
  function tandai(halaman) {
    document.querySelectorAll('.nav-btn').forEach(function (b) {
      b.classList.toggle('on', b.dataset.page === halaman);
    });
  }
  document.addEventListener('click', function (e) {
    var b = e.target.closest('.nav-btn');
    if (!b) return;
    tandai(b.dataset.page);
    Shiny.setInputValue('nav_pilih', b.dataset.page, {priority: 'event'});
    window.scrollTo(0, 0);
  });
  // menu ikut berubah bila halaman dipindah dari tombol lain (mis. "Unggah Dataset")
  $(document).on('shiny:inputchanged', function (e) {
    if (e.name === 'menu') { tandai(e.value); window.scrollTo(0, 0); }
  });
})();
