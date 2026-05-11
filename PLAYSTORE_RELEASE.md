# Play Store release checklist

Project ini sudah disiapkan untuk rilis Android dengan package ID:

- `com.ti24a6.app28`

## 1. Buat upload keystore

Jalankan dari root project:

```powershell
keytool -genkeypair -v -keystore android/app/keystore/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

## 2. Aktifkan signing release

1. Salin `android/key.properties.example` menjadi `android/key.properties`
2. Isi password dan path keystore yang benar

Contoh:

```properties
storePassword=your-keystore-password
keyPassword=your-key-password
keyAlias=upload
storeFile=keystore/upload-keystore.jks
```

## 3. Versi aplikasi

Versi saat ini sudah disiapkan di `pubspec.yaml`:

```yaml
version: 1.0.1+2
```

`1.0.1` = versi yang tampil di Play Store, `2` = build number / version code.

## 4. Build App Bundle

```powershell
flutter build appbundle
```

Hasil file:

- `build/app/outputs/bundle/release/app-release.aab`

## 5. Upload ke Play Console

Sebelum upload, siapkan juga:

- icon aplikasi final
- screenshot aplikasi
- deskripsi aplikasi
- privacy policy jika diperlukan
- kategori aplikasi dan rating konten

## Catatan

- Project lokal ini sudah memiliki upload keystore dan `android/key.properties`.
- Backup file `android/app/keystore/upload-keystore.jks` dengan aman karena itu identitas signing aplikasi Anda.
- Icon launcher Android mengikuti gaya icon login Boncosin.
