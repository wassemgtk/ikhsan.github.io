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
extension NSDate {
    static func rmdn_ramadhanDaysForHijriYear(year: Int) -> [NSDate] {
        guard let hijriCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierIslamic) else { return [] }

        let components = NSDateComponents()
        components.month = 9 // Ramadhan adalah bulan ke 9 di tahun Hijriah
        components.year = year

        // menggunakan flatMap bukan map,
        // karena dateFromComponents mungkin mengembalikan optional NSDate
        return (1..<30).flatMap { day in
            components.day = day
            return hijriCalendar.dateFromComponents(components)
        }
    }
}
```

### Lokasi

Kita perlu mengetahui titik kordinat sebuah kota hanya dari namanya. Untungnya CoreLocation mempunyai fungai yang mentransformasikan nama kota menjadi sebuah tempat yang terbungkus dalam objek, `CLPlacemark`.

```swift
CLGeocoder().geocodeAddressString("London") { p, error in
    guard let placemark = p?.first else {
        completionHandler([])
        return
    }

    placemark // CLPlacemark dengan sebuah tempat di London
}
```

### Waktu Solat

Pemikiran pertama untuk mendapatkan jadwal solat adalah dengan memanggil API seperti [MuslimSalat](http://muslimsalat.com/api/) atau [xchanch](http://xhanch.com/xhanch-api-islamic-get-prayer-time/). Namun sebisa mungkin kita ingin meminimalisir ketergantungan program kita dengan aplikasi lain karena jika aplikasi tersebut tidak bisa diakses maka program kita tidak bisa berjalan.

Saya pengguna sebuah aplikasi bernama [Guidance](http://guidanceapp.com). Ternyata penghitung waktu solatnya dibuka sebagai proyek _open source_, yaitu [`BAPrayerTimes`](https://github.com/batoulapps/BAPrayerTimes). Dengan `BAPrayerTimes`, kita bisa menghitung waktu solat tanpa perlu membuat _network call_.

```swift

private func prayerTimesForDate(date: NSDate, placemark: CLPlacemark) -> BAPrayerTimes? {
    guard let latitude = placemark.location?.coordinate.latitude,
        let longitude = placemark.location?.coordinate.longitude,
        let timeZone = placemark.timeZone else {
            return nil
    }

    return BAPrayerTimes(
        date: date,
        latitude: latitude,
        longitude: longitude,
        timeZone: timeZone,
        method: BAPrayerMethod.MCW,
        madhab: BAPrayerMadhab.Hanafi
    )
}

```

### _Wrap Up_

Setelah mendapatkan informasi yang dibutuhkan, kita bungkus informasi dalam satu hari pada sebuah struct yang bernama, `RamadhanSummary`. Bila tertarik melihat seluruh kode untuk mengkoleksi data bisa lihat pada [`DataCollection.swift`](https://github.com/ikhsan/FutureOfRamadhan/blob/master/FutureRamadhans/DataCollection.swift)

---

## Visualisasi Data

Tidak ada yang spesial dari bagaimana

senenernya tidak ada yg spesial, saya menggunakan colextionview dan custom drawredt pada cellnya

### Bar Chart

Untuk setiap ramadhan summary, digambarkan sbg sebuah custom cell.
Bar yg berwarna menunjukan waktu mulai dan selesainha berpuasa, sedangkan warnanya menunjukan durasi berpuasanaya
Dg sedikit brmain dg skala kita bisa menempatkan letak mulai. Dan panjangbar dg akurat

### Warna

warna

### Menyimpan `UICollectionView` sebagai gambar

menyimpan `UICollectionView` sebagai gambar

### Hasil Akhir

Hasil akhir

![Ramadhan around the world](blog/2015-08-06-future-of-ramadhan/ramadhans.png)

## Kesimpulan

Kalau mau, pake swift suh asik2 aja untuk visualisasi
Apalagi banyak feaneweok (apple dna 3rd party yg bisa kita gunakan)

Alangkah kerennya bula kita busa fuanajan scripting. Maka kra tidak perlu lagi pakai xcode hanya u/ mnejalankan aplikasi. Sayangnya skrng masi blm bbisa krn geocodernya tidak halan. <rdar>

link source code : https://github.com/ikhsan/FutureOfRamadhan

Mungkin nanti klo udah jalan bisa saya konversi sbg string dan bisa dijalanakn dr command line

### Referensi
- dat vis @ udacity
- bapeayertimes
