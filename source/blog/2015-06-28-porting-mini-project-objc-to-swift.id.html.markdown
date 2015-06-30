---
title: Kesan Pertama Mengubah Kode dari Objective-C ke Swift
date: 2015-06-28 16:18 UTC
tags: objective-c, swift
---

Setelah melihat beberapa video WWDC dalam 2 minggu terakhir, saya akhirnya mencoba fitur-fitur baru dari xcode 7 dan Swift. Sekedar iseng-iseng, saya menggunakan program sederhana yang saya buat tahun lalu untuk coding test dari [Songkick](https://api.songkick.com). Saya namakan "__On Tour__", ide dasar aplikasinya adalah untuk melihat jalur tur band-band kesayangan di peta.

< gambar >

Berikut adalah beberapa catatan dan kesan saya saat mencoba menulis ulang prototipe fitur saya dari objective-C ke swift 2.0.

## Error Handling
Fitur bahasa yang memaksa kita untuk memikirkan lebih seksama dengan error handling, seperti optional, guard, throw.

### Optional
xxx

### Guard
xxx

### Throws
xxx

## Enumeration + Generics = Result Enum

http://natashatherobot.com/swift-generics-box/

Kombinasi enum and generics pada swift sangatlah _powerful_. Ini bukanlah hal baru pada Swift, kita sudah bisa menggunakan kekuatan enumeration sejak versi pertama dari Swift.

```swift
enum Result<T, Error: ErrorType> {
    case Success(T)
    case Failure(Error)
}
```

Result cocok untuk asynchronous result.

Coba bandingkan method-method ini. Perhatikan value type parameternya.

```objc
+ (NSURLSessionDataTask *)searchArtist:(NSString *)name
    page:(NSUInteger)page
    completion:(void (^)(NSArray *results, NSError *error))completion;
```

```swift
class func searchArtist(
  name: String,
  page: Int = 1,
  completionHandler: (Result<[Artist], ErrorType>) -> Void
)
```

## @Testable

http://natashatherobot.com/swift-2-xcode-7-unit-testing-access/

## Jumlah Baris pada Kode
Jumlah baris kode bukanlah metrik penentu kualitas sebuah kode, namun untuk mencari metrik yang sederhana maka akan tetap saya gunakan. Menulis kode Swift harus lebih terinci karena sifatnya _type safety_, walau begitu jumlah baris kodenya lebih sedikit dibanding Objective-C.

Untuk menghitung jumlah baris kode, kita bisa menggunakan perintah `find` dari terminal:

```sh
$ find . \( -iname \*.m -o -iname \*.h -o -iname \*.swift \) -exec wc -l '{}' \+
```

Kode Objective-C

* total +-1370 baris
* dua file yang melebihi 200 baris, yaitu sebuah kelas `ViewController` dan kelas Networking untuk API.

Kode Swift

* total +-980 baris [^1]
* maksimal jumlah baris untuk sebuah file : 145 baris untuk sebuah kelas `ViewController`

Menggunakan Swift memang membuat kode menjadi lebih ramping. Sintaks Swift terlihat lebih sederhana dan lebih nyaman dilihat. Tidak ada detil rumit yang tidak perlu, seperti bintang untuk _pointer_, dua bintang untuk passing `NSError` dan titik koma pada akhir baris.

Compiler Swift juga pintar dalam menyimpulkan tipe data. Sehingga kita tidak perlu menulis secara gamblang semua tipe variabel atau fungsi seperti yang kita lakukan di Objective-C.

Terakhir, saya menggunakan `class extension` pada kelas-kelas berbeda sehingga saya bisa memisahkan tanggung jawab dari satu kelas ke beberapa file terpisah.

## Limitation

UI testing masih suka crash dan rusak2, terutama kalau klik2 dengan cepat

Tooling masih suka crash, walau sudah jauh lebih baik dari sebelumnya. yang saya sayangkan fitur playground yang masih sangat fragile. Saya sering suka membuka playground untuk mengecek kebenaran ide di kepala saya  sebelum digabungkan di aplikasi utama. Namun apa daya karena suka crash akhirnya saya koding langsung di aplikasi utama.

## Kesimpulan

Ini adalah waktu yang exciting untuk menjadi Swift developer. kenapa?

Fitur-fitur bahasa ini masih akan terus berubah dan berkembang.


[^1]: Saya sedikit curang karena pada kode Swift karena menggunakan sebuah library pemilahan JSON yang tidak saya masukkan dalam perhitungan. Di Swift, pemilahan data JSON yang sederhana sekalipun menurut saya masih dirasa ribet dan memang masih menjadi topik diskusi yang aktif di komunitas Swift. Sehingga saya memutuskan untuk menggunakan SwiftyJSON pada Podfile saya untuk menyederhanakan masalah.
