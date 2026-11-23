# Cadangan GarudaPanel Installer

Repositori publik ini menyimpan salinan installer GarudaPanel. Proyek dan installer aslinya adalah karya **The GarudaPanel Authors**, bukan karya pemilik repositori ini. Pemberitahuan hak cipta dan lisensi `AGPL-3.0-or-later` tetap tercantum pada installer.

## Status cadangan

Cadangan rilis upstream **0.1.21** disimpan sebagai **draft GitHub Release**: paket Linux amd64 dan arm64, `LATEST`, `SHA256SUMS`, tanda tangan `SHA256SUMS.sig`, installer asli, dan catatan rilis bahasa Inggris serta Indonesia. Draft hanya dapat diakses oleh pihak yang berwenang pada repositori; tidak dapat diunduh secara anonim atau dipakai sebagai sumber unduhan publik installer.

Manifest dan tanda tangannya berasal dari upstream. Tanda tangan Ed25519 diverifikasi menggunakan kunci publik di installer asli; checksum kedua paket, installer asli, dan catatan rilis cocok dengan manifest. Arsip kode sumber 0.1.21 yang tercantum dalam manifest tidak tersedia saat dicari di server upstream. Karena itu, jangan menganggap cadangan ini sudah lengkap atau pendistribusian binarinya sudah memenuhi kewajiban lisensi. Dapatkan source yang sesuai dari pengembang sebelum meninjau publikasi binari.

## Installer dan keterbatasan

Installer pada cabang `main` masih memakai server rilis GarudaPanel. Varian yang diarahkan ke GitHub disiapkan sebagai berkas `garudapanel-installer.sh` pada draft release; varian ini mempertahankan pemeriksaan tanda tangan dan checksum upstream, tetapi **unduhan GitHub belum berfungsi selama release masih draft**. Tidak ada pengujian instalasi penuh yang dilakukan.

Paket menyebut perangkat lunak ini **pre-alpha** dan belum siap untuk produksi. Binari masih mengandung alamat GarudaPanel; belum diketahui apakah instalasi, pembaruan, atau operasi panel bergantung pada alamat tersebut. Memindahkan file installer dan paket saja belum membuktikan bahwa panel dapat berjalan mandiri jika hosting GarudaPanel mati. Source yang sesuai diperlukan untuk meninjau dan mengubah ketergantungan internal, kemudian harus diuji di lingkungan terisolasi.

Rujukan upstream: [halaman sumber GarudaPanel](https://garudapanel.my.id/source).
