---
title: Menambahkan Fitur Slather
date: 2015-06-07 23:47 UTC
tags: ruby, slather, objective-c
---

Bulan lalu, saya mengunjungi kantor Facebook London untuk berpartisipasi dalam acaranya Cocoapods, [Test Jam](http://blog.cocoapods.org/Test-Jammin/). Inti acaranya adalah menambahkan test code ke pods yang sudah ada bersama-sama sebagai satu komunitas. Saat itulah saya mengenal yang namanya __Slather__ untuk pertama kali. READMORE

[Slather](https://github.com/venmo/slather) adalah ruby gem yang menghasilkan laporan ulasan kode dari Xcode project dan mengintegrasikannya ke CI. Instalasinya cukup mudah, tinggal mengikuti [pedoman](https://github.com/venmo/slather#installation) yang tersedia.

Setelah project terpasang dengan servis _code coverage_ seperti [coveralls](https://coveralls.io), kita bisa meninjau hasil _coverage_ kode melalui laman webnya. Dasbor coveralls memberikan informasi yang dibutuhkan; total persentase, table data dari tiap file dan kode yang bersangkutan.

![Coveralls Report Table](/extending-slather/coveralls_1.png)

## Penggunaan secara Lokal : Laporan HTML

Seringkali, kita juga ingin mempunyai akses informasi yang sama dengan dasbor Coveralls tanpa harus update kode kita ke remote repository dan mengunjungi situsnya.

Dengan Slather, kita bisa mendapatkan informasi sederhana dengan *simple output mode* menggunakan `-s`. Tapi untuk saya, ini tidak memberikan detil yang cukup. Kita hanya mendapatkan persentase untuk tiap file, tapi tanpa informasi __baris mana__ yang ter-_cover_. Saya tidak mau selalu update kode saya ke remote repository tiap kali ingin mengecek baris mana yang telah ter-_cover_.

Saya pikir, kenapa saya tidak tambahkan saja fitur ini ke Slather? Keren kan kalau bisa menghasilkan reports sebagai laman HTML statik. Menggunakan file HTML berarti kita tidak perlu konfigurasi tambahan, aplikasi lain atau bahkan koneksi internet. Hanya perlu browser saja dan bisa langsung pakai.

Langkah pertama adalah bagaimana cara menambahkan fitur. Dengan mencari _pull request_ yang telah terintegrasi, kita dapat mempelajari bagaimana orang lain menambahkan fitur ke sebuah project. Saya menggunakan PR-nya [neonichu]((https://github.com/neonichu)) saat dia menambahkan fitur [GutterJSON](https://github.com/venmo/slather/pull/24/files?diff=split) sebagai panduan saya. Sedikit tips, adalah gunakan _file diffing_-nya Github untuk melihat jelas apa-apa saja yang ditambahkan.

Saya bukan desainer handal, jadi saya mengikuti saja apa yang sekiranya sudah terbukti. Slather sudah punya logo yang cakep, saya gunakan saja skema warnanya. Lalu saya jiplak plek-plek _styling_-nya Coveralls, termasuk desain tabel dan tampilan kodenya. Kredit untuk beberapa _library_ yang saya gunakan, sorotan pada kode menggunakan [`highlight.js`](https://highlightjs.org/), pengurutan dan filter menggunakan [list.js](http://www.listjs.com/).

![Coveralls Report Table](/extending-slather/slather_html_1.png)
![Coveralls Line Coverage](/extending-slather/slather_html_2.png)

Untuk membangkitkan laporan html, gunakan opsi `--html`. Perintah ini akan menampilkan path dari laman indeks, tapi bisa juga gunakan opsi `--show` untuk membuka laporan secara otomatis di perambah.

```sh
$ slather coverage --html --show path/to/project.xcodeproj
```

## Kode telah terintegrasi 🎉

Sejujurnya, ini adalah pengalaman kali pertama dalam kontribusi open source yang terasa nyata. Respons dari lainnya sangat memotivasi dan hasilnya cukup membanggakan. Sangat diharapkan fitur ini akan digunakan banyak orang. Pembangkitan [laporan HTML code coverage](https://github.com/venmo/slather/pull/76) sudah terintegrasi ke Slather 1.8. Asik dah.

### Update WWDC15 : Xcode 7 telah memiliki fitur code coverage

Saat WWDC15 kemarin, Apple mengumumkan bahwa fitur _code coverage_ telah tersedia di Xcode. Pemgembang dapat melihat di dalam aplikasi baris kode mana yang sudah ter-_cover_. Apakah ini berarti Slather dengan laporan HTML-nya sia-sia?

Pendapat saya laporan HTML tetap mempunyai keunggulannya tersendiri. HTML tidak tertempel pada Xcode, yang artinya laporan tersebut bisa dimacam-macamkan. Bisa digunakan untuk cek secara lokal tanpa internet, bisa diunggah di website, atau bisa juga ditempel di Jenkins. Masih banyak lah kemungkinan-kemungkinan lain yang bisa dieksplor dengan laporan HTML ini, jadi tentu saja masih punya nilainya tersendiri.
