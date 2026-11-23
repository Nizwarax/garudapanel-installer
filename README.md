# GarudaPanel Installer — mirror GitHub

Repositori ini menyimpan salinan installer GarudaPanel dan paket rilis pada GitHub. Ini adalah mirror, bukan klaim bahwa proyek atau binari aslinya dibuat oleh pemilik repositori. Atribusi dan pemberitahuan lisensi upstream tetap dipertahankan.

## Instalasi dari GitHub

```bash
curl -fsSL https://raw.githubusercontent.com/Nizwarax/garudapanel-installer/main/garudapanel-installer.sh | sudo bash
```

Secara default, `garudapanel-installer.sh` mengambil `LATEST`, manifest checksum, tanda tangan, dan paket hanya dari GitHub Releases repositori ini. Instalasi lokal tanpa mengunduh tersedia melalui opsi `--bundle` bila paket dan `SHA256SUMS` berada di komputer yang sama. `GARUDAPANEL_RELEASES` dapat mengubah alamat mirror jika memang disetel oleh operator.

## Status rilis 0.1.21

Rilis cadangan GitHub 0.1.21 saat ini masih **draft**. Asetnya tersimpan di akun pemilik repo, tetapi belum bisa diunduh publik; karena itu installer online belum dapat dipakai oleh publik sampai ada rilis publik yang layak.

Paket amd64 dan arm64 serta manifest/signature upstream tersedia. Namun, manifest mencantumkan arsip source `garudapanel-0.1.21-source.tar.gz` dengan SHA-256 `d6d863344ed8184b29344908226bd319f52d47e82db8a2419bce05398248f6e5`, dan arsip tersebut tidak tersedia. Jangan memublikasikan binari ini sebagai rilis publik sebelum source yang cocok dan hak/ketentuan distribusinya dipastikan. Pemberitahuan saat ini tetap menyebut `The GarudaPanel Authors` dan `AGPL-3.0-or-later`; jangan menggantinya tanpa source serta teks lisensi/hak yang berlaku.

## Yang belum mandiri

Mengalihkan unduhan installer ke GitHub hanya menghilangkan ketergantungan installer pada server unduhan GarudaPanel. Pemeriksaan string pada binari menemukan alamat GarudaPanel untuk `/docs`, `/releases`, dan `/source`. Belum diketahui apakah alamat itu benar-benar dipanggil saat instalasi atau panel berjalan, dan paket berstatus **pre-alpha** serta belum siap untuk produksi. Tanpa source lengkap yang cocok, alamat internal itu tidak dapat ditinjau atau diganti secara aman; kemandirian runtime belum terbukti.

Agar seluruh proyek benar-benar mandiri, diperlukan arsip source lengkap GarudaPanel 0.1.21 yang cocok dengan checksum di atas, lalu perubahan dan pengujian untuk seluruh endpoint internal. Untuk mengubah atribusi atau lisensi juga diperlukan teks pemberitahuan/hak yang tepat dan sesuai dengan izin yang berlaku.
