---
title: Fastlane di Jenkins dan Permasalahannya
date: 2015-06-09 04:32 UTC
tags: ruby, fastlane, jenkins
---

__Fastlane__ akan membantu kita dalam mengkonfigurasi jalur _deployment_ yang kita punya. Ada beberapa keuntungan dalam menggunakan fastlane, apapun Continuous Integration (CI) yang kita gunakan, mau itu Travis di _cloud_, Jenkins di mesin CI lokal atau bahkan mesin yang kita gunakan untuk pengembangan. READMORE [Fastlane](https://fastlane.tools) terdiri dari berbagai kakas untuk berbagai kepentingan pula. Tempat pertama yang perlu kita cek adalah [daftar perintah-perintah](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md) yang bisa digunakan.

Memulai cukup cepat dan mudah. Fastlane bahkan punya asisten yang akan membantu kita _nyetting_ di awal.

```sh
$ (sudo) gem install fastlane
$ cd <folder dasar project>
$ fastlane init
```

Dan kita sudah siap! 👌

## Keuntungan dibanding Jenkins Biasa

### Bisa Digunakan di manapun
Fastlane dapat dijalankan di semua mesin yang terinstall ruby dan gem yang bersangkutan. Permulaan saya menggunakan Fastlane adalah saat kami di tempat kerja sedang pindah kantor, sehingga tidak punya akses ke server Jenkins. Namun, klien tetap ingin selalu terupdate dengan build terbaru. Dengan menggunakan Fastlane beserta file konfigurasinya, semua developer bisa membuat build yang sama tanpa perlu akses ke Jenkins.

### Konfigurasi Tersimpan dalam Repositori

File konfigurasi (yang bernama `Fastfile`) hanya berupa file teks biasa, jadi kita bisa dengan mudah menyimpannya dalam repositori. Kita bahkan tidak perlu lancar berbahasa Ruby karena sintaksnya yang mirip dengan bahasa Inggris biasa.

### Integrasi dengan Jenkins (yang Seharusnya Mudah)

Fastlane mempunyai [panduan singkat](https://github.com/KrauseFx/fastlane/blob/master/docs/Jenkins.md) untuk pengintegrasiannya dengan Jenkins. Kalau Jenkins dan Fastlane sudah terinstall, kita tinggal membuat job baru yang punya dua pekerjaan, mengambil kode sumber dari repositori (dengan plugin git atau SVN) dan mengeksekusi skrip perintah Fastlane (`fastlane <nama jalur>`).

## Problem with Jenkins

Integrasi dengan Jenkins semestinya mudah, namun saya menemukan beberapa masalah berdasarkan pengalaman saya.

### Jenkins Menggunakan Ruby dengan Versi yang Berbeda

Pertama kali menjalankan _job_ di Jenkins, ia komplen karena tidak bisa mendeteksi perintah `Fastlane`. Setelah dicek kembali dengan ssh, tampaknya semua telah terinstall dan baik-baik saja. Ternyata [solusinya cukup mudah](http://stackoverflow.com/a/10519349/851515), tinggal menggunakan _flag_ `-l` agar menggunakan shell yang sama saat login.

__'Execute shell' di Jenkins__

```sh
#!/bin/bash -l

# Saya sudah mengkofigurasi jalur bernama 'build' di `Fastfile`
fastlane build
```

### Keychain yang Terkunci

Saya pernah mendapatkan error terkait code signing, yang menyebutkan bahwa keychain tidak bisa diakses karena terkunci. Solusi untuk masalah ini adalah menggunakan kakas `unlock-keychain` dengan password admin Anda.

__Execute shell__

```sh
security -v unlock-keychain -p "<password admin>" "/Users/<username>/Library/Keychains/login.keychain"
fastlane build
```

### Error pada Codesigning
Ini sebenarnya bukan masalah spesifik untuk Jenkins, tapi kalau Anda bertemu masalah dengan pesan error seperti [ini](http://stackoverflow.com/a/26499526/851515): "`/tmp/QYFSJIvu7W/Payload/XX.app/ResourceRules.plist: cannot read resources`", maka kita perlu menambahkan file `"ResourceRules.plist"` ke dalam konfigurasi proyek di Xcode.

* Klik target dari proyek Xcode > Build Settings > Code Signing Resource Rules Path
* Tambahkan `$(SDKROOT)/ResourceRules.plist`

### Error pada Codesigning (Lagi)
Saya menemukan masalah ini saat menggunakan dua parameter dari perintah [ipa](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md#ipa) : `'embed'` and `'identity'`. Perintah ini menggunakan kakas `codesign` didalamnya. Tapi saya menemukan pesan error yang berujar `"code failed to satisfy specified code requirement(s)"`. Sedikit googling, saya langsung menemukan sebuah [artikel](http://blog.hoachuck.biz/blog/2013/10/29/codesign-useful-info-in-xcode-5-dot-0-1/) yang menerangkan bahwa saya mempunyai path `codesign_allocate` yang salah.

Solusi dari permasalahan ini adalah dengan menambahkan `path` tersebut secara "paksa". Kita bisa melakukannya di skrip dalam Jenkins (opsi execute shell) atau menambahkannya di Fastfile kita. Kalau saya tinggal menambahkannya saja di Fastfile;

```ruby
platform :ios do
  desc "Making a build"
  lane :build do

    # Pengkoreksian path untuk kakas codesign_allocate
    ENV['CODESIGN_ALLOCATE'] = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate"

    ipa(
      configuration: "Debug",
      scheme: 'MyApp', # skema aplikasi
      destination: "build", # direktori tujuan
      embed: 'fastlane/my_distribution_cert.mobileprovision',
      identity: 'iPhone Distribution: Ikhsan Assaat',
    )
  end
end
```
