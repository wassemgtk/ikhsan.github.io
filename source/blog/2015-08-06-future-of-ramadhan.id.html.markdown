---
title: "Visualisasi Data dengan Swift : Ramadhan di Masa Depan"
date: 2015-08-06 09:21 UTC
tags: swift
---

Pengalaman berpuasa di London membuat saya ingin mengetahui bagaimana rasanya berpuasa di kota-kota lain di seluruh dunia. Untuk itu saya membuat visualisasi sederhana untuk menjawab rasa penasaran tersebut. READMORE

Situasi ini juga menjadi alasan yang baik untuk berlatih Swift. Mungkin d3 akan menjadi kakas yang paling cocok untuk visualisasi data, namun karena ini hanya sekedar main-main, ya sekalian saja bermain dengan Swift 2.0.

## Koleksi Data

### Tanggal Ramadhan

Hal pertama yang ingin kita ketahui adalah kapan saja bulan Ramadhan jatuh di masa mendatang. Ini bisa dijawab dengan `NSCalendar` karena kelas tersebut mempunyai jenis kalender islam (hijriah). Dengan ini kita bisa mendaftar tanggal-tanggal bulan Ramadhan pada 25 tahun ke depan.

```swift
extension NSDate {
    static func rmdn_ramadhanDaysForHijriYear(year: Int) -> [NSDate] {
        guard let hijriCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierIslamic) else {
          return []
        }

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

Kita perlu mengetahui titik kordinat sebuah kota hanya dengan namanya. Untungnya `CoreLocation` mempunyai fungsi untuk mentransformasikan nama kota menjadi lokasi yang dibungkus dalam objek `CLPlacemark`.

```swift
CLGeocoder().geocodeAddressString("London") { p, error in
    guard let placemark = p?.first else {
        return
    }

    placemark // CLPlacemark dengan sebuah tempat di London
}
```

### Waktu Solat

Pemikiran pertama untuk mendapatkan jadwal solat adalah dengan memanggil API seperti [MuslimSalat](http://muslimsalat.com/api/) atau [xchanch](http://xhanch.com/xhanch-api-islamic-get-prayer-time/). Namun sebisa mungkin kita ingin meminimalisir ketergantungan aplikasi kita dengan aplikasi lain karena jika API tidak bisa diakses maka aplikasi kita tidak bisa jalan.

Sehari-hari saya menggunakan aplikasi [Guidance](http://guidanceapp.com) untuk mengecek jadwal solat. Ternyata penghitung waktu solatnya dibuka sebagai proyek _open source_, [`BAPrayerTimes`](https://github.com/batoulapps/BAPrayerTimes). Dengan `BAPrayerTimes`, kita bisa menghitung waktu solat tanpa perlu membuat _network call_.

```swift
func prayerTimesForDate(date: NSDate, placemark: CLPlacemark) -> BAPrayerTimes? {
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

### `RamadhanSummary`

Setelah mendapatkan informasi yang dibutuhkan, kita bungkus informasi dalam sekali Ramadhan pada sebuah `struct` yang kita namakan [`RamadhanSummary`](https://github.com/ikhsan/FutureOfRamadhan/blob/master/FutureRamadhans/DataCollection.swift#L6).

## Visualisasi Data

Tidak ada yang spesial dalam memvisualisasikan informasi puasa dalam bentuk grafik. Menggambar grafik yang diinginkan cukup dengan menggunakan fitur gambar sederhana dari Core Graphics.

### Bar

Sebuah `RamadhanSummary` terpetakan sebagai sebuah `UICollectionViewCell` di `UICollectionView`. Panjang sebuah bar berasal dari durasi lamanya berpuasa, sedangkan letak barnya tergantung dari jam mulai dan jam berakhirnya berpuasa. Dengan menggunakan skala yang tepat kita bisa memposisikan bar tersebut ditempat yang tepat. Kita tambahkan _tick_ untuk setiap dua jam untuk mempermudah pembacaan jam.

### Warna

Pewarnaan untuk bar juga ditentukan oleh durasi berpuasa yang relatif terhadap bentangan durasi terpendek dan terpanjang dari semua Ramadhan pada sebuah lokasi. Durasi minimal diwarnai hijau (`rgb(46, 204, 113)`) sedangkan durasi maksimal diwarnai warna orange (`rgb(243, 156, 18)`).

Untuk menentukan warna, kita membutuhkan dua parameter yaitu bentang minimal dan maksimal durasi puasa, dan durasi pada tahun yang ingin dicari. Umpama London mendapat Ramadhan terpendek dengan durasi 14 jam dan terpanjang 20 jam, lalu bagaimana kita menentukanwarna untuk durasi Ramadhan yang 18 jam? Hal ini mungkin lebih terbayang jika kita lihat coret-coretan di bawah ini;

```
durasi 14  |------------[18]--------| 20

red    46  |------------[??]--------| 243
green  204 |------------[??]--------| 156
blue   113 |------------{??}--------| 18
```
Perhitungan warna ini ditranslasikan menjadi kode Swift sebagai berikut;

```swift
extension UIColor {
    class func colorForDuration(duration: Double, range: (min: Double, max: Double)) -> UIColor {
        let minColor: (Double, Double, Double) = (46, 204, 113)
        let maxColor: (Double, Double, Double) = (243, 156, 18)

        let r = minColor.0 + ((maxColor.0 - minColor.0) * ((duration - range.min) / (range.max - range.min)))
        let g = minColor.1 + ((maxColor.1 - minColor.1) * ((duration - range.min) / (range.max - range.min)))
        let b = minColor.2 + ((maxColor.2 - minColor.2) * ((duration - range.min) / (range.max - range.min)))

        return UIColor(
            colorLiteralRed: Float(r / 255.0),
            green: Float(g / 255.0),
            blue: Float(b / 255.0),
            alpha: 1.0
        )
    }
}

// perhitungan warna
let color = UIColor.colorForDuration(18.0, range:(14.0, 20.0)) // rgb(177, 172, 49)
```

### Menyimpan `UICollectionView` sebagai gambar

Setelah seluruh bar telah diposisikan dan diwarnai dengan benar, kita perlu menyimpan seluruh bar sebagai berkas gambar. Kita bisa membuatnya dengan menggunakan `UIGraphicsGetImageFromCurrentImageContext()`. Namun, [kita harus set `frame` `UICollectionView`](http://stackoverflow.com/a/14376719/851515) kita dengan `contentSize`-nya agar seluruh konten dari `UICollectionView` terdeteksi.

```swift
extension UICollectionView {
    func rmdn_takeSnapshot() -> UIImage {
        let oldFrame = self.frame

        var frame = self.frame
        frame.size.height = self.contentSize.height // ubah sebelum snapshot
        self.frame = frame

        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.opaque, 0)
        self.layer.renderInContext(UIGraphicsGetCurrentContext())
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.frame = oldFrame // ubah kembali ke ukuran sebelumnya

        return screenshot
    }
}
```
Setelah `UICollectionView` menjadi `UIImage`, kita bisa menyimpannya ke dalam direktori dokumen (`DocumentDirectory`). Bila penyimpanan berhasil, fungsi akan mengembalikan sebuah `path` ke berkas gambar tersebut.

```swift
extension UIImage {
    func rmdn_saveImageWithName(name: String) -> String {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first,
            let image = UIImagePNGRepresentation(self) else {
                return ""
        }

        let filepath = documentPath.stringByAppendingPathComponent("\(name).png")
        let success = image.writeToFile(filepath, atomically: true)
        return success ? filepath : ""
    }
}
```

## Hasil Akhir

Berikut visualisasi durasi berpuasa dari kota [London](2015-08-06-future-of-ramadhan/london.png), [Tokyo](2015-08-06-future-of-ramadhan/tokyo.png), [Reykjavik](2015-08-06-future-of-ramadhan/reykjavik.png) dan [Wellington](2015-08-06-future-of-ramadhan/wellington.png).

![Ramadhan around the world](blog/2015-08-06-future-of-ramadhan/ramadhans.png)

## Kesimpulan

Cukup asyik menggunakan Swift sebagai kakas visualisasi data karena banyak _framework_ dari Apple maupun 3rd party yang bisa kita gunakan. Fitur bahasa seperti `guard` dan fungsi-fungsi `CollectionType` membuat menulis dan membaca kode menjadi lebih menyenangkan. Untuk mencobanya, bisa lihat di laman [Github](https://github.com/ikhsan/FutureOfRamadhan).

Ke depannya, akan lebih asyik lagi jika aplikasi ini dijalankan sebagai _playground_. Kita tidak perlu lagi Xcode dan simulator hanya untuk menjalankan aplikasinya. Sayangnya, kita belum bisa menggunakan CoreLocation secara sempurna di playground, karena fitur geocoding tidak berjalan dengan sempurna. Jika fitur geocodingnya berfungsi dengan benar, kita juga bisa jalankan kode ini sebuah _script_ sehingga bisa dijalankan dari terminal.

## Referensi

- [Data Visualization and D3.js Course](https://www.udacity.com/course/data-visualization-and-d3js--ud507) by Udacity
- [`BAPrayerTimes`](https://github.com/batoulapps/BAPrayerTimes) by Batoul Apps
- [Guidance for Mac and iOS](http://guidanceapp.com) by Batoul Apps
