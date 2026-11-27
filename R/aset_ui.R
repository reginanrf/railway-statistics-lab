# ==== aset_ui.R =====================================================
# CSS dan JS aplikasi (mengikuti Railway_Statistics_Lab_v3.html).
# Dibenamkan di sini agar ikut termuat otomatis bersama folder R/.

css_rsl <- r"---(/* Railway Statistics Lab — gaya mengikuti Railway_Statistics_Lab_v3.html (moodboard RSL) */
:root{--pri:#5B4BE8;--pri-d:#3F2FC2;--sec:#8A3FD8;--acc:#F28A2E;--mag:#D9468A;
--bg:#F3F4FB;--card:#fff;--tile:#EEF0FF;--tx:#1B1B3A;--mu:#6A6B8A;--bd:#E3E5F4;--ok:#17A86B;--wr:#C98310;--er:#E0405A;
--grad:linear-gradient(135deg,#5B4BE8,#8A3FD8);--r-sm:10px;--r-md:14px;--r-lg:20px;
--sh:0 8px 24px rgba(63,47,194,.10);--sh-btn:0 6px 16px rgba(91,75,232,.35);
--mono:'JetBrains Mono',ui-monospace,monospace;
--bs-body-bg:var(--bg);--bs-body-color:var(--tx);--bs-border-color:var(--bd)}
@media(prefers-color-scheme:dark){:root{--bg:#12112A;--card:#1C1B3A;--tile:#27255A;--tx:#EEEEFF;--mu:#A5A6C8;--bd:#33316A;--pri:#7C6DF5;--ok:#3DCB8A;--wr:#F2B14F;--er:#FF6B82;--sh:0 8px 24px rgba(0,0,0,.35)}}
*{box-sizing:border-box}
html{scroll-padding-top:env(safe-area-inset-top,0px)}
body{margin:0;background:var(--bg);color:var(--tx);font-size:14px;line-height:1.55}
.container-fluid{padding:0!important}

/* ===== SHELL + SIDEBAR ===== */
.rsl-shell{display:flex;min-height:100vh}
.rsl-nav{width:252px;background:var(--card);border-right:1px solid var(--bd);padding:0 14px 20px;position:sticky;top:0;height:100vh;overflow-y:auto;flex-shrink:0}
.brand{display:flex;gap:12px;align-items:center;margin:0 -14px 16px;padding:20px 18px 18px;border-bottom:1px solid var(--bd)}
.logo{width:40px;height:40px;border-radius:50%;background:linear-gradient(135deg,var(--pri),var(--mag));display:grid;place-items:center;color:#fff;flex-shrink:0}
.brand h1{font-size:14px;margin:0;line-height:1.25;font-weight:800;color:var(--tx);min-width:0}
.brand small{display:block;font-weight:500;color:var(--mu);font-size:11px;margin-top:2px}
.rsl-nav button.nav-btn{display:flex;gap:10px;align-items:center;width:100%;text-align:left;background:none;border:0;color:var(--mu);padding:11px 12px;border-radius:var(--r-md);font-weight:600;font-size:14px;cursor:pointer;margin-bottom:4px}
.rsl-nav button.nav-btn:hover{background:var(--tile)}
.rsl-nav button.nav-btn.on{background:var(--tile);color:var(--pri)}
.rsl-nav svg,.logo svg,.sic svg{width:20px;height:20px;fill:none;stroke:currentColor;stroke-width:1.8;stroke-linecap:round;stroke-linejoin:round;flex-shrink:0}
.rsl-main{flex:1;min-width:0;padding:0 0 32px}
.rsl-main .tab-content>.tab-pane{padding:0}
/* isi halaman dibungkus .pg (lihat page_body() di utils_ui.R): padding kiri-kanan 28px */
.pg{padding:0 28px}
.pg.pg-top{padding-top:24px}

/* ===== HEADINGS ===== */
h2{margin:0 0 4px;font-size:26px;font-weight:800;letter-spacing:-.02em}
h3{margin:0 0 10px;font-size:16px;font-weight:700}
.mu,.text-muted{color:var(--mu)!important}

/* ===== HEADER HALAMAN (.ph) — sama di semua halaman: judul [lencana] + subjudul =====
   .ph: pita putih selebar area utama, garis bawah penuh. .ph-in: padding kiri-kanan sama dengan .pg */
.ph{background:var(--card);border-bottom:1px solid var(--bd);margin:0 0 20px}
.ph-in{padding:14px 28px}
.ph-row{display:flex;align-items:center;gap:10px;flex-wrap:wrap}
.ph h2{margin:0;font-size:22px;line-height:1.25}
.ph-sub{margin:2px 0 0;font-size:12.5px;line-height:1.45;color:var(--mu)}

/* ===== CARD / GRID ===== */
.card{background:var(--card);border:1px solid var(--bd);border-radius:var(--r-lg);padding:20px;margin-bottom:16px;box-shadow:var(--sh);color:var(--tx)}
.g{display:grid;gap:16px;margin-bottom:16px}.g>.card,.g>div>.card:last-child{margin-bottom:0}
.g4{grid-template-columns:repeat(auto-fit,minmax(190px,1fr))}.g2{grid-template-columns:repeat(auto-fit,minmax(320px,1fr))}
.g>*{min-width:0}
.st{position:relative;overflow:hidden}
.st span{color:var(--mu);font-size:12px;font-weight:600;display:block}
.st b{display:block;font-size:28px;line-height:1.15;margin:4px 0;font-weight:800;letter-spacing:-.02em;font-variant-numeric:tabular-nums}
.st::before{content:"";position:absolute;left:0;top:14px;bottom:14px;width:4px;border-radius:0 4px 4px 0;background:var(--pri)}
.st b.per{font-size:17px;line-height:1.4}.hi{color:var(--acc)}
.empty{text-align:center;padding:40px 16px;color:var(--mu);border-style:dashed;border-width:2px}
.empty .btn{align-self:center}
.empty h3{color:var(--tx)}.empty .fa,.empty svg{color:var(--pri)}
.infobar{display:flex;flex-direction:row;justify-content:space-between;align-items:center;gap:12px;flex-wrap:wrap}

/* ===== HERO / BAND ===== */
.hero{background:linear-gradient(135deg,#5B4BE8 0%,#8A3FD8 60%,#D9468A 100%);color:#fff;border-radius:var(--r-lg);padding:28px;margin-bottom:16px;box-shadow:var(--sh-btn)}
.hero h2{font-size:32px;color:#fff}.hero p{margin:6px 0 16px;max-width:620px;opacity:.92}
.rail{height:5px;margin-top:18px;border-radius:3px;background:repeating-linear-gradient(90deg,rgba(255,255,255,.55) 0 14px,transparent 14px 20px)}
.band{background:var(--grad);color:#fff;border-radius:var(--r-lg);padding:18px 24px;display:flex;justify-content:space-between;align-items:center;gap:14px;flex-wrap:wrap;margin-bottom:16px;box-shadow:var(--sh-btn)}
.band small{font-size:12px;font-weight:700;opacity:.85}
.bn{font-size:20px;font-weight:800;display:flex;gap:8px;align-items:center;flex-wrap:wrap}.bn .badge{background:#fff!important}
.hero .btn,.band .btn{background:#fff!important;color:var(--pri-d)!important;box-shadow:none}
.hero .btn.s,.band .btn.s{background:rgba(255,255,255,.16)!important;color:#fff!important;border:1px solid rgba(255,255,255,.55)!important}
.hero .btn+.btn{margin-left:8px}
.band .btn+.btn{margin-left:8px}

/* ===== SHORTCUT CARDS ===== */
.sc3{grid-template-columns:repeat(3,minmax(0,1fr))}
.sct{text-align:left;cursor:pointer;background:var(--card);border:1px solid var(--bd);border-radius:var(--r-lg);padding:18px;box-shadow:var(--sh);color:var(--tx);display:flex;flex-direction:column;align-items:flex-start;width:100%;transition:transform .12s}
.sct:hover{transform:translateY(-2px)}.sct b{display:block;font-size:16px}.sct p{margin:2px 0 0;color:var(--mu);font-size:13px}
.sic{width:44px;height:44px;border-radius:50%;display:grid;place-items:center;color:#fff;margin-bottom:10px}.sic svg{width:22px;height:22px}

/* ===== BUTTON ===== */
.btn,.btn-primary,.btn-default,.btn-file{background:var(--grad)!important;color:#fff!important;border:0!important;border-radius:var(--r-md)!important;padding:11px 20px;font-weight:700;font-size:14px;box-shadow:var(--sh-btn);transition:transform .1s}
.btn:hover{transform:translateY(-1px)}
.btn.s,.btn-outline-primary,.btn-sm.btn-outline-primary{background:var(--tile)!important;color:var(--pri)!important;box-shadow:none;border:0!important}
.btn-sm{padding:8px 14px;font-size:13px}
.btn[disabled]{opacity:.4;cursor:not-allowed;transform:none}
.btn:focus-visible,input:focus-visible,select:focus-visible,.nav-btn:focus-visible{outline:3px solid rgba(91,75,232,.35);outline-offset:2px}
.btn-block,.cfg .btn,.cfg .action-button{width:100%}
.data-action-buttons {display: flex;flex-direction: column;gap: 10px;width: 100%;margin-top: 12px;}
.data-action-buttons .btn {width: 100%;margin: 0 !important;}

/* ===== BADGE / ALERT ===== */
.badge{display:inline-block;padding:3px 12px;border-radius:99px;font-size:12px;font-weight:700;background:color-mix(in srgb,currentColor 14%,transparent)!important;border:0}
.badge.ok{color:var(--ok)}.badge.wr{color:var(--wr)}.badge.er{color:var(--er)}.badge.mu{color:var(--mu);background:var(--tile)!important}
.msg,.alert{padding:12px 16px;border-radius:var(--r-md);border:0;border-left:4px solid currentColor;background:color-mix(in srgb,currentColor 10%,var(--card));margin-bottom:12px;font-weight:500}
.msg.wr,.alert-warning{color:var(--wr)}.msg.er,.alert-danger{color:var(--er)}.msg.ok{color:var(--ok)}
.msg *,.alert *{color:inherit}

/* ===== FORM ===== */
.filter-bar {display: grid;grid-template-columns: minmax(0, 1.8fr) repeat(3, minmax(0, 1fr));gap: 12px;align-items: end;margin-bottom: 12px;}
.fb {display: flex;flex-wrap: wrap;gap: 12px;align-items: flex-end;margin-bottom: 12px;}
.filter-bar > .shiny-input-container,
.filter-bar > .form-group {width: 100%;min-width: 0;}
.filter-bar .input-daterange {display: flex;width: 100%;min-width: 0;gap: 4px;}
.filter-bar .input-daterange input {flex: 1 1 0;width: 50%;min-width: 0;padding: 9px 22px 9px 7px !important;font-size: 11px;}
.filter-bar > .btn {grid-column: span 2;width: 100%;white-space: nowrap;}
@media(max-width:800px) {
  .filter-bar {grid-template-columns: repeat(2, minmax(0, 1fr));}
  .filter-bar > .btn {grid-column: span 1;}
  .filter-bar > .shiny-input-container:has(.input-daterange) {grid-column: span 2;}
}

@media(max-width:560px) {
  .filter-bar {grid-template-columns: minmax(0, 1fr);}
  .filter-bar > .shiny-input-container:has(.input-daterange) {grid-column: span 1;}
}
.filter-bar .btn-outline-primary {background: transparent !important;color: var(--pri) !important;box-shadow: none !important;border: 1.5px solid var(--pri) !important;}
.filter-bar .btn.s {background: var(--grad) !important;color: #fff !important;box-shadow: var(--sh-btn) !important;border: 0 !important;}
.filter-bar .btn.s:hover {filter: brightness(1.08);}
.filter-bar .form-group,
.filter-bar .shiny-input-container {
  margin-bottom: 0;
  width: 100%;
  min-width: 0;
}

.fb .shiny-input-container {
  margin-bottom: 0;
  width: auto;
}
label,.control-label{display:flex;flex-direction:column;font-size:12px;font-weight:700;color:var(--mu);gap:4px;margin-bottom:4px}
input.form-control,select.form-select,select.form-control,.selectize-input,.input-daterange input{background:var(--card)!important;color:var(--tx)!important;border:1.5px solid var(--bd)!important;border-radius:12px!important;padding:9px 12px;font-weight:500;font-size:14px;min-height:42px;box-shadow:none}
.filter-bar .input-daterange input {
  background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='18' height='18' viewBox='0 0 24 24' fill='none' stroke='%236A6B8A' stroke-width='1.8' stroke-linecap='round' stroke-linejoin='round'%3E%3Crect x='3' y='5' width='18' height='16' rx='2'/%3E%3Cpath d='M16 3v4M8 3v4M3 11h18'/%3E%3C/svg%3E") !important;
  background-repeat: no-repeat !important;
  background-position: right 12px center !important;
  background-size: 16px 16px !important;
  padding-right: 36px !important;
}
input.form-control:focus,select:focus,.selectize-input.focus{border-color:var(--pri)!important;outline:0;box-shadow:0 0 0 4px rgba(91,75,232,.15)!important}
.input-daterange{display:flex;align-items:center;gap:6px}.input-daterange .input-group-addon,.input-daterange .input-group-text{display:none}
.filter-bar .shiny-input-container:has(select[id$="-jenis"]) .selectize-control,
.filter-bar .shiny-input-container:has(select[id$="-stasiun"]) .selectize-control {min-width: 120px;}
.filter-bar .selectize-control.single .selectize-input {padding-right: 30px !important;}
.input-group .btn-file{border-radius:var(--r-md)!important;margin-right:8px;padding-left:10px;padding-right:10px;}
.input-group > .form-control{flex:1 1 auto;min-width:0;width:1%;}
.shiny-input-container .progress{height:16px;border-radius:6px;background:var(--tile);margin-top:8px;margin-bottom:2px;}.progress-bar{background:var(--pri)}
.shiny-input-container:has(#data-berkas_progress){margin-bottom:4px;}
.cfg .filter-bar {display: grid;grid-template-columns: minmax(0, 1fr);gap: 12px;}
.cfg .filter-bar > .btn {grid-column: span 1;width: 100%;}
.cfg .fb {display: flex;flex-direction: column;align-items: stretch;gap: 12px;}
.cfg .fb > div {width: 100%;min-width: 0;}
.cfg label,
.cfg select,
.cfg input,
.cfg .shiny-input-container,
.cfg .form-group {width: 100%;min-width: 0;}
.cfg .selectize-control,
.cfg .selectize-input {width: 100%;min-width: 0;}

/* ===== ANALISIS: wadah putih + tab garis bawah ===== */
.an-wrap{
  /* ATUR PADDING WADAH ANALISIS DI SINI */
  --an-pad-top:32px;      /* jarak tab ke tepi atas wadah */
  --an-pad-x:24px;        /* jarak kiri & kanan */
  --an-pad-bottom:24px;   /* jarak ke tepi bawah */
  --tab-pad-top:10px;     /* jarak teks tab ke atas */
  --tab-pad-bottom:16px;  /* jarak teks tab ke garis bawah */
  background:var(--card);border:1px solid var(--bd);border-radius:24px;padding:var(--an-pad-top) var(--an-pad-x) var(--an-pad-bottom);box-shadow:var(--sh)}
.an-wrap .card{box-shadow:0 2px 10px rgba(63,47,194,.06)}
.utabs{display:flex;gap:24px;border-bottom:1px solid var(--bd);margin:0 0 20px;white-space:nowrap}
.utabs .form-group,.utabs .shiny-input-container{margin:0!important;width:auto!important;max-width:none}
.utabs .control-label,.utabs .shiny-label-null{display:none!important}
.utabs .shiny-options-group{display:flex;gap:24px}
.utabs .radio,.utabs .radio-inline,.utabs .form-check,.utabs .form-check-inline{margin:0!important;padding:0!important;min-height:0;display:block}
.utabs label{display:block;margin:0 0 -1px!important;padding:var(--tab-pad-top) 2px var(--tab-pad-bottom)!important;font-weight:700;font-size:13px;line-height:1.3;color:var(--mu);cursor:pointer;border:0;border-bottom:3px solid transparent;text-decoration:none!important}
.utabs label:hover{color:var(--tx)}
.utabs label:has(input:checked),.utabs input:checked+label{color:var(--pri);border-bottom-color:var(--pri)}
.utabs label.radio-inline {padding-bottom: 16px !important;}
.utabs input{position:absolute!important;opacity:0;width:0;height:0;margin:0;pointer-events:none;appearance:none}
/* hasil: satu kartu berisi judul+unduh, tabel, grafik, catatan */
.hasil>*+*{margin-top:16px}
.hasil .fb{margin-bottom:0}
.hasil .msg:last-child{margin-bottom:0}
/* tombol Reset di panel pengaturan: outline */
.cfg .btn-outline-primary,.cfg .btn-sm.btn-outline-primary{background:transparent!important;border:1.5px solid var(--pri)!important;color:var(--pri)!important;box-shadow:none}

/* ===== TABLE + DT ===== */
.tw{overflow-x:auto}
table{border-collapse:collapse;width:100%;font-size:13px;font-variant-numeric:tabular-nums;color:var(--tx)}
table.table>:not(caption)>*>*{background:transparent;color:var(--tx);box-shadow:none}
th,td{padding:9px 12px;border-bottom:1px solid var(--bd);text-align:left;white-space:nowrap}
th{background:var(--tile)!important;color:var(--pri)!important;font-weight:700;font-size:12px;border-top:0}
th:first-child{border-radius:10px 0 0 10px}th:last-child{border-radius:0 10px 10px 0}
th small{font:500 10px var(--mono);color:var(--mu);display:block}
tr:hover td{background:color-mix(in srgb,var(--tile) 45%,transparent)!important}
td.dt-right,td.r{text-align:right}
.dataTables_wrapper{font-size:13px;color:var(--mu)}
.dataTables_wrapper input,.dataTables_wrapper select{border:1.5px solid var(--bd);border-radius:12px;background:var(--card);color:var(--tx);padding:6px 10px}
.dataTables_wrapper .dataTables_filter {float: none;text-align: left;width: 100%;margin-bottom: 12px;}
.dataTables_wrapper .dataTables_filter label {display: flex;flex-direction: row;align-items: center;gap: 10px;width: 100%;margin: 0;white-space: nowrap;}
.dataTables_wrapper .dataTables_filter input {flex: 1;width: auto;min-width: 0;max-width: none;margin: 0;}
.dataTables_wrapper .dataTables_paginate .paginate_button{border-radius:10px!important;color:var(--mu)!important;border:0!important}
.dataTables_wrapper .dataTables_paginate .paginate_button.current{background:var(--tile)!important;color:var(--pri)!important}
table.dataTable.no-footer{border-bottom:0}table.dataTable thead th,table.dataTable thead td{border-bottom:1px solid var(--bd)}

/* ===== ANALISIS LAYOUT ===== */
.split{display:grid;grid-template-columns:300px minmax(0,1fr);gap:16px;align-items:start}
.cfg{position:sticky;top:16px;margin-bottom:0}
.res .fb{justify-content:space-between;align-items:center}
.ip{border-left:4px solid var(--acc);background:var(--tile);border-radius:var(--r-md);padding:12px 12px 12px 32px;margin-bottom:10px}
.ip li{margin-bottom:6px}.ip li:last-child{margin-bottom:0}
.rsl-data-grid{grid-template-columns:minmax(280px,1fr) 2fr;align-items:start}

/* ===== PLOTLY / GRAFIK (ikut tema terang/gelap) ===== */
.js-plotly-plot .gtitle,.js-plotly-plot .xtick text,.js-plotly-plot .ytick text,.js-plotly-plot .xtitle,.js-plotly-plot .ytitle,.js-plotly-plot .legendtext{fill:var(--mu)!important}
.js-plotly-plot .gtitle{fill:var(--tx)!important;font-weight:700}
.js-plotly-plot .bg,.js-plotly-plot .plotbg .bg{fill:transparent!important}
.js-plotly-plot .gridlayer path{stroke:var(--bd)!important}
.card .html-widget{width:100%!important}

/* ===== RESPONSIF ===== */
@media(max-width:1000px){.split{grid-template-columns:minmax(0,1fr)}.cfg{position:static}.sc3{grid-template-columns:repeat(2,minmax(0,1fr))}.rsl-data-grid{grid-template-columns:minmax(0,1fr)}}
@media(max-width:800px){
 .rsl-shell{display:block}
 .rsl-nav{width:100%;height:auto;position:static;display:flex;flex-wrap:nowrap;gap:4px;padding:10px;overflow-x:auto;border-right:0;border-bottom:1px solid var(--bd);align-items:center}
 .brand{margin:0 10px 0 0;padding:0;border-bottom:0}.brand small{display:none}.brand h1{white-space:nowrap;font-size:13px}
 .rsl-nav .nav-links{display:flex;gap:4px}.rsl-nav button.nav-btn{width:auto;white-space:nowrap;padding:9px 12px;margin:0}
 .rsl-main{padding:0 0 24px;max-width:100vw;overflow-x:hidden}
 .pg{padding:0 16px}.pg.pg-top{padding-top:16px}
 .ph{margin-bottom:16px}.ph-in{padding:12px 16px}.ph h2{font-size:20px}
 .an-wrap{--an-pad-top:18px;--an-pad-x:14px;--an-pad-bottom:14px;border-radius:18px}
 .utabs{overflow-x:auto;overflow-y:hidden;gap:18px}.utabs .shiny-options-group{gap:18px}.utabs label{margin-bottom:0!important}
 .hero{padding:20px}.hero h2{font-size:24px}}
@media(max-width:560px){.sc3{grid-template-columns:1fr}}
)---"

js_rsl <- r"---(// Navigasi sidebar: kirim pilihan ke server, tandai menu aktif, gulir ke atas.
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
)---"
