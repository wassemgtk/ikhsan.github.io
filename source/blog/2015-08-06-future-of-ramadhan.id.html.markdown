---
title: "Visualisasi Data dengan Swift : Ramadhan di Masa Depan"
date: 2015-08-06 09:21 UTC
tags: swift
---

Berawal dari pengalaman berpuasa di luar Indonesia, saya mempunyai keingintahuan dengan puasa-puasa di belahan dunia lain.

READMORE

- berawal dari pengalaman berpuasa di uk, saya mempinyai keingi tahuan akan berouasasi kot2 lain di sleiruh  dumia
- rasa penasaran tsb dapat dijawab dg memvisualisasikannya dr data

- pikir saya, aha ini bisa menjasiclatian yg baik u/ mnggunakan swift
- tool yg terpikir pertama pasti d3.js, namun krn ini hanya proeyk iseng2 maka saya pakai swift saja

Berikut adalah beberapa snippet yg sekiranya menarik

Data collection

Kita ingin tahu tanggal2 bulan ramadhan untuk 25 taun ke depan. Krn nscalendar support islamic calender, in cukup mudah. Kita bisa buat sebuah function pada extension nsdat
<snippet>

Location
Kita ingin agar hisa mendapstkan titik coordinate dr sebuah nama kota. D geocoding, kita bisa memanggil method dr corelicatin dan mendapatkan data dr tempar tersebu sbg objek clplacemark

<snippet>

waktu solat
Untuk mencari waktu solat, ada beberapa cara untuk mendapatkan ya. Awalmya saya berencana nenggunakan 3rd partyy api untuk inj. Namun ada cara yg lebih mudah tnapa perlu network call, yaitu baprayertimed
 Ini dibuat oleh penciptanya guidance, dg pod 'baprayertime' maka tak perlu repot2 lagi mendapatkan timetable untuk prayer

<snippets>

Dg mengkombonasikan semuanya, kita bisa wrap data tersebut sebagj tamadhan summary

<snippet>


Data visualization
- senenernya tidak ada yg spesial, saya menggunakan colextionview dan custom drawredt pada cellnya

Untuk setiap ramadhan summary, digambarkan sbg sebuah custom cell.
Bar yg berwarna menunjukan waktu mulai dan selesainha berpuasa, sedangkan warnanya menunjukan durasi berpuasanaya

Dg sedikit brmain dg skala kita bisa menempatkan letak mulai. Dan panjangbar dg akurat

Warna bar

Saving collection as imagw

Conclussion

Kalau mau, pake swift suh asik2 aja untukvisualisasi
Apalagi banyak feaneweok (apple dna 3rd party yg bisa kita gunakan)

Alangkah kerennya bula kita busa fuanajan scripting. Maka kra tidak perlu lagi pakai xcode hanya u/ mnejalankan aplikasi. Sayangnya skrng masi blm bbisa krn geocodernya tidak halan. <rdar>

link source code : https://github.com/ikhsan/FutureOfRamadhan

Mungkin nanti klo udah jalan bisa saya concert sbg string dan bisa dijalanakn dr command line

Ref:
- dat vis @ udacity
- bapeayertimes

![Ramadhan around the world](blog/2015-08-06-future-of-ramadhan/ramadhans.png)
