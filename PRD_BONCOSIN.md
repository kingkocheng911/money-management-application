# Product Requirements Document

## Product name

Boncosin

## Document version

- Version: 1.0
- Date: 7 Mei 2026
- Owner: mr.k

## 1. Latar belakang

Boncosin adalah aplikasi mobile pencatatan keuangan pribadi yang membantu pengguna mencatat pemasukan dan pengeluaran harian secara cepat, sederhana, dan mudah dipahami. Banyak pengguna masih mencatat keuangan secara manual atau tidak konsisten, sehingga sulit mengetahui kondisi saldo, pola pengeluaran, dan kategori pengeluaran terbesar.

Boncosin dikembangkan untuk menyediakan pengalaman pencatatan keuangan yang ringan, modern, dan mudah digunakan oleh pengguna umum maupun mahasiswa.

## 2. Tujuan produk

Tujuan utama Boncosin:

- membantu pengguna mencatat pemasukan dan pengeluaran harian
- menampilkan saldo berjalan secara real-time
- memberikan ringkasan keuangan sederhana yang mudah dipahami
- menampilkan analisis pengeluaran berdasarkan kategori dan periode
- mendorong kebiasaan pengelolaan uang yang lebih teratur

## 3. Problem statement

Masalah yang ingin diselesaikan:

- pengguna sering lupa mencatat transaksi harian
- pengguna tidak memiliki gambaran saldo terkini
- pengguna sulit melihat pengeluaran terbesar per kategori
- pencatatan manual di buku atau chat tidak efisien dan sulit dianalisis

## 4. Target pengguna

Target pengguna utama:

- mahasiswa
- pelajar
- pengguna individu yang ingin mencatat keuangan pribadi
- pengguna yang membutuhkan aplikasi pencatatan keuangan sederhana tanpa integrasi bank

## 5. Value proposition

Nilai utama Boncosin:

- pencatatan transaksi cepat dan sederhana
- tampilan modern dan nyaman dipakai
- analitik keuangan ringan langsung di dalam aplikasi
- data tersimpan lokal sehingga mudah digunakan tanpa akun online

## 6. Platform dan teknologi

- Platform utama: Android
- Framework: Flutter
- Bahasa: Dart
- Penyimpanan lokal: SharedPreferences
- Visual analytics: `fl_chart`
- Bahasa/locale utama: Indonesia

## 7. Ruang lingkup versi saat ini

Fitur yang sudah tercermin pada aplikasi saat ini:

- login sederhana berbasis data lokal
- registrasi akun lokal
- penyimpanan status login
- pencatatan pemasukan
- pencatatan pengeluaran
- input nama transaksi
- input nominal transaksi
- input tanggal transaksi
- pemilihan kategori transaksi
- perhitungan saldo, total pemasukan, dan total pengeluaran
- riwayat transaksi yang dikelompokkan per hari
- halaman analitik bulanan
- grafik tren saldo
- diagram kategori pengeluaran
- filter riwayat transaksi pada halaman analitik
- profil pengguna
- mode gelap
- logout

## 8. Fitur utama dan requirement

### 8.1 Autentikasi lokal

Deskripsi:
Pengguna dapat masuk menggunakan username dan password yang disimpan di perangkat.

Functional requirements:

- pengguna dapat mengisi username dan password
- sistem memvalidasi kecocokan data login dengan data lokal
- sistem menampilkan pesan error jika data salah atau kosong
- sistem menyimpan status login agar pengguna tidak perlu login ulang setiap membuka aplikasi

Acceptance criteria:

- jika username dan password benar, pengguna masuk ke halaman utama
- jika salah satu field kosong, sistem menolak login
- jika data salah, sistem menampilkan pesan kesalahan

### 8.2 Registrasi akun lokal

Deskripsi:
Pengguna dapat membuat akun lokal sebagai identitas penggunaan aplikasi.

Functional requirements:

- pengguna dapat membuat username dan password
- data akun disimpan di penyimpanan lokal
- sistem memvalidasi input agar data tidak kosong

Acceptance criteria:

- akun baru dapat digunakan untuk login
- data akun tetap tersedia setelah aplikasi ditutup dan dibuka kembali

### 8.3 Dashboard keuangan

Deskripsi:
Halaman utama menampilkan ringkasan keuangan pengguna.

Functional requirements:

- sistem menampilkan nama pengguna
- sistem menampilkan saldo berjalan
- sistem menampilkan total pemasukan
- sistem menampilkan total pengeluaran
- sistem menampilkan riwayat transaksi terbaru

Acceptance criteria:

- setelah transaksi ditambahkan, nilai saldo dan ringkasan berubah otomatis
- data transaksi tampil terurut dari yang terbaru

### 8.4 Pencatatan transaksi

Deskripsi:
Pengguna dapat menambah transaksi pemasukan dan pengeluaran.

Functional requirements:

- pengguna dapat memilih jenis transaksi: pemasukan atau pengeluaran
- pengguna dapat mengisi nominal transaksi
- pengguna dapat mengisi nama transaksi
- pengguna dapat memilih kategori transaksi
- pengguna dapat memilih tanggal transaksi
- transaksi disimpan secara lokal

Acceptance criteria:

- transaksi baru langsung muncul di riwayat
- pemasukan menambah saldo
- pengeluaran mengurangi saldo

### 8.5 Riwayat transaksi

Deskripsi:
Pengguna dapat melihat daftar transaksi yang sudah dicatat.

Functional requirements:

- transaksi dikelompokkan berdasarkan hari seperti "Hari ini", "Kemarin", atau tanggal tertentu
- setiap item menampilkan nama, kategori, tanggal, dan nominal
- urutan default adalah dari transaksi terbaru

Acceptance criteria:

- transaksi yang ditambahkan pada hari yang sama muncul dalam grup yang benar
- transaksi lama tetap tersimpan setelah aplikasi dibuka ulang

### 8.6 Analitik keuangan

Deskripsi:
Pengguna dapat melihat analisis transaksi bulanan.

Functional requirements:

- pengguna dapat melihat transaksi per bulan
- sistem menghitung total pemasukan dan pengeluaran bulanan
- sistem menampilkan grafik tren saldo
- sistem menampilkan distribusi pengeluaran per kategori
- sistem menyediakan filter urutan riwayat analitik

Acceptance criteria:

- grafik dan ringkasan berubah sesuai bulan yang dipilih
- kategori pengeluaran terbesar tampil pada analisis

### 8.7 Profil dan preferensi

Deskripsi:
Pengguna dapat melihat identitas singkat dan mengatur preferensi aplikasi.

Functional requirements:

- sistem menampilkan nama pengguna
- pengguna dapat mengaktifkan atau menonaktifkan mode gelap
- pengguna dapat logout dari aplikasi

Acceptance criteria:

- status mode gelap tersimpan setelah aplikasi ditutup
- logout menghapus status login aktif

## 9. Non-functional requirements

- aplikasi harus berjalan dalam orientasi portrait
- tampilan harus responsif untuk ukuran layar ponsel umum
- data lokal harus tetap tersedia setelah aplikasi ditutup
- navigasi dasar harus terasa cepat dan sederhana
- bahasa antarmuka utama menggunakan Bahasa Indonesia
- aplikasi harus tetap dapat berjalan tanpa koneksi internet untuk fitur inti

## 10. User flow utama

### Flow 1: Registrasi dan login

1. Pengguna membuka aplikasi
2. Jika belum login, pengguna masuk ke halaman login
3. Pengguna membuat akun atau login dengan akun yang sudah ada
4. Sistem menyimpan status login
5. Pengguna diarahkan ke dashboard

### Flow 2: Menambah transaksi

1. Pengguna membuka dashboard
2. Pengguna memilih tambah pemasukan atau tambah pengeluaran
3. Pengguna mengisi nominal, nama transaksi, kategori, dan tanggal
4. Pengguna menyimpan transaksi
5. Sistem memperbarui saldo dan riwayat

### Flow 3: Melihat analitik

1. Pengguna membuka halaman analitik
2. Pengguna memilih bulan
3. Sistem menampilkan grafik tren, pie chart kategori, dan riwayat terkait

## 11. User stories

- Sebagai pengguna, saya ingin login dengan akun saya agar bisa mengakses data keuangan pribadi saya.
- Sebagai pengguna, saya ingin menambah pemasukan agar saldo saya terhitung otomatis.
- Sebagai pengguna, saya ingin menambah pengeluaran agar saya tahu ke mana uang saya keluar.
- Sebagai pengguna, saya ingin melihat total pemasukan dan pengeluaran agar saya bisa memahami kondisi keuangan saya.
- Sebagai pengguna, saya ingin melihat analitik per kategori agar saya tahu pengeluaran terbesar saya.
- Sebagai pengguna, saya ingin mengaktifkan mode gelap agar aplikasi lebih nyaman digunakan.

## 12. KPI / indikator keberhasilan

Indikator keberhasilan awal:

- pengguna dapat menyelesaikan login tanpa error
- pengguna dapat menambahkan transaksi dalam kurang dari 30 detik
- saldo dan ringkasan berubah akurat setelah transaksi ditambahkan
- pengguna dapat melihat analitik bulanan tanpa crash
- aplikasi berhasil dibangun dan dirilis ke Play Store

## 13. Risiko dan batasan

Risiko:

- data hanya tersimpan lokal sehingga dapat hilang jika aplikasi dihapus
- belum ada sinkronisasi cloud atau backup akun
- autentikasi masih sederhana dan belum memakai enkripsi tingkat lanjut

Batasan versi saat ini:

- belum ada edit transaksi
- belum ada hapus transaksi secara eksplisit
- belum ada ekspor data
- belum ada notifikasi pengingat pencatatan
- belum ada multi-device sync

## 14. Future enhancement

Pengembangan yang disarankan untuk versi berikutnya:

- edit dan hapus transaksi
- pencarian dan filter transaksi
- ekspor ke PDF atau Excel
- backup dan restore data
- sinkronisasi akun berbasis cloud
- target anggaran bulanan
- notifikasi pengingat harian
- keamanan dengan PIN atau biometrik

## 15. Release scope v1.0.1

Scope rilis yang siap dipublikasikan:

- package name Android sudah sesuai Play Console: `com.ti24a6.app28`
- signing release sudah dikonfigurasi
- app bundle `.aab` sudah berhasil dibuat
- identitas aplikasi menggunakan nama Boncosin
- aset icon launcher Android sudah disiapkan

## 16. Kesimpulan

Boncosin adalah aplikasi pencatat keuangan pribadi yang fokus pada kemudahan penggunaan, pencatatan cepat, dan visualisasi sederhana. Produk ini cocok sebagai solusi awal untuk membantu pengguna memahami pemasukan, pengeluaran, dan saldo mereka setiap hari. Dengan pengembangan lanjutan pada backup data, keamanan, dan pengelolaan transaksi, Boncosin memiliki ruang untuk berkembang menjadi aplikasi keuangan pribadi yang lebih matang.
