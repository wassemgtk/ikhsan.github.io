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

Langkah pertama adalah bagaimana cara menambahkan fitur. Dengan mencari pull request yang telah terintegrasi, kita dapat 

First step is to find how to add features. By just browsing the list of merged pull request, you will able to see how people are adding stuff to the project. I used [neonichu](https://github.com/neonichu)'s [GutterJsonOutput PR](https://github.com/venmo/slather/pull/24/files?diff=split) as a guide. Use github's file diffing to learn how a good contribution looks like.

I'm not of a designer so I followed what already worked. Slather already has a delightful logo, so I used its colour scheme. Then I replicate coveralls styling for the tables and the highlighted source code. Syntax highlighting is using [`highlight.js`](https://highlightjs.org/) and sorting-filtering is using [list.js](http://www.listjs.com/).

![Coveralls Report Table](/extending-slather/slather_html_1.png)
![Coveralls Line Coverage](/extending-slather/slather_html_2.png)

To generate the html report, use the `--html` flag. It will print the path of the index page by default, but you can use you could use '--show' flag to open it automatically in your browser.

```sh
$ slather coverage --html --show path/to/project.xcodeproj
```

## Kode telah terupdate 🎉

Honestly, this is my first real experience on open source contribution. The responses from others are motivating and the end result was rewarding. I really hope that it will be used by many people. [HTML reports generation](https://github.com/venmo/slather/pull/76) is merged to slather 1.8 update. Woohoo.

### Update WWDC15 : Xcode 7 telah memiliki fitur code coverage

In WWDC 15, Apple announced code coverage support baked into Xcode. Developers would able to see right inside the code which lines are covered. Does it mean that slather + html reports will be futile?

I think slather with HTML report has its own advantages. HTMLs are not attached to Xcode, meaning you can do whatever you want with it. Whether to do local review, upload to your site, or integrate it to Jenkins. IMO, there are still values on having slather generating HTML reports.
