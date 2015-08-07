---
title: "Visualisasi Data dengan Swift : Ramadhan di Masa Depan"
date: 2015-08-06 09:21 UTC
tags: swift
---

Pengalaman berpuasa di Inggris membuat saya ingin mengetahui bagaimana rasanya berpuasa di kota-kota lain di seluruh dunia. Untuk itu saya membuat visualisasi sederhana untuk menjawab rasa penasaran tersebut. READMORE

Selain itu, ini situasi ini menjadi alasan yang baik untuk kembali berlatih dengan Swift. Mungkin d3 akan menjadi kakas yang paling cocok untuk situasi seperti ini, namun karena ini hanya sekedar iseng ya sekalian saja bermain-main dengan Swift 2.0.

## Koleksi Data

### Tanggal Ramadhan

Hal pertama yang ingin kita ketahui adalah pada tanggal berapa bulan ramadhan di masa mendatang. Ini bisa dijawab dengan `NSCalendar` karena kelas tersebut mempunyai jenis kalender islam (hijriah). Dengan ini kita bisa mendaftar tanggal-tanggal bulan Ramadhan pada 25 tahun ke depan. Fungsi ini saya tempatkan di ekstensi kelas `NSDate`.

```swift
// NSDate+RamadhanDays.swift

extension NSDate {
    static func rmdn_ramadhanDaysForHijriYear(year: Int) -> [NSDate] {
        guard let hijriCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierIslamic) else { return [] }

        let components = NSDateComponents()
        // Ramadhan adalah bulan ke 9 di tahun Hijriah
        components.month = 9
        components.year = year

        // menggunakan flatMap bukan map,
        // karena dateFromComponents mungkin mengembalikan NSDate atau nil
        return (1..<30).flatMap { day in
            components.day = day
            return hijriCalendar.dateFromComponents(components)
        }
    }
}
```

---

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
