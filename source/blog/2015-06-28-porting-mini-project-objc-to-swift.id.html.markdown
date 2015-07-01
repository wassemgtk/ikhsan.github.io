---
title: Kesan Pertama Mengubah Kode dari Objective-C ke Swift
date: 2015-06-28 16:18 UTC
tags: objective-c, swift
---

Setelah melihat beberapa video WWDC dalam 2 minggu terakhir, saya akhirnya mencoba fitur-fitur baru dari xcode 7 dan Swift. Sekedar iseng-iseng, saya menggunakan prototipe aplikasi sederhana yang saya buat tahun lalu untuk coding test dari [Songkick](https://api.songkick.com). READMORE Saya namakan "__On Tour__", ide dasar aplikasinya adalah untuk melihat jalur tur band-band kesayangan kita di peta.

![On Tour](blog/2015-06-28-porting-mini-project-objc-to-swift/ontour.gif)

Berikut adalah beberapa catatan dan kesan saya saat mencoba menulis ulang prototipe fitur saya dari Objective-C ke Swift 2.0.

## Error Handling
Ada beberapa fitur bahasa Swift yang menurut saya sengaja dirancang agar kita memikirkan lebih seksama dengan penanganan error. Beberapa diantaranya adalah Optional, Guard dan Throws.

### Optional
Secara implisit seluruh objek yang kita buat dalam Objective-C adalah Optionals. Karena objek selain punya nilai, tapi bisa juga tidak (atau nil).

Lihat cuplikan kelas `Artist` yang saya tulis untuk Objective-C;

```objc
@interface Artist : NSObject
@property (nonatomic, strong) NSNumber *artistID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *onDateTour;
@end
```

Tidak jelas terlihat dari ketiga properti, mana yang harus dipunyai seorang artis dan mana yang tidak. Bahkan kita bisa saja membuat sebuah objek artis tanpa properti sama sekali. Ini memaksa kita untuk ekstra hati-hati dalam mengolah sebuah kelas, karena compiler tidak punya pengetahuan terlalu jauh dan seluruh logika akan berada sepenuhnya di tangan developer.

Sekarang kita lihat kelas sama yang ditulis dengan Swift;

```swift
class Artist {
  var id: String
  var name: String
  var onTourDate: NSDate?
}
```
Dalam cuplikan kode di atas, Swift akan menjamin bahwa properti `id` dan `name` akan selalu ada di sebuah objek `Artist`. Satu-satunya properti yang mungkin tidak dipunyai seorang `Artist` adalah `onTourDate`, karena mungkin saja artis tersebut sedang membuat album dan mengurangi jadwal turnya. Dengan Optional, compiler dapat ikut membantu developer dalam memodelkan sebuah logika.

### Guard
Guard adalah fitur baru yang diperkenalkan di Swift 2.0. Saya membiasakan untuk menerapkan 'early exit' (atau kadang disebut bouncer pattern) dalam menangani error. Alasannya adalah karena pola ini mengajak saya untuk memikirkan penganganan error di awal blok kode saya. Selain itu saya menghemat indentasi karena 'happy path' tetap di bagian kiri kode, bukan dalam if statement.

```swift
// ArtistViewController.swift

var artist: Artist?

func openArtist() {
  guard let a = artist else {
    return
  }
  // a dipastikan adalah artist yang valid
  openArtist(a)
}
```

### Throws

Swift 2.0 juga memperkenalkan penanganan error default, yang berbeda dengan Objective-C. Mungkin programmer Java sudah cukup familiar dengan konsep try/catch, namun di Swift agak sedikit berbeda, do/try/throws/catch. Bahkan di SDK Apple terkini, beberapa method sudah mengadopsi konsep ini.

Sebagai contoh, lihat bagaimana biasa kita mengubah NSData menjadi NSDictionary di Objective-C

```objc
// header
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;

// implementation
NSError *error = nil;
id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
if (error) {
  // penanganan error
  return;
}
// result dapat digunakan di sini
```

Sedangkan pada Swift 2.0, memanggil method yang sama menjadi lebih mudah dimengerti dan pengangan error berada pada kode blok yang berbeda.

```swift
// header
class func JSONObjectWithData(data: NSData, options opt: NSJSONReadingOptions) throws -> AnyObject

// implementation
do {
  let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
  // result dapat digunakan di sini
} catch {
  // penanganan error
}
```

## Enum + Generics = Result

Sayangnya throws tidak cocok dalam sync calls.
alasan.
selengkapnya: https://gist.github.com/nicklockwood/21495c2015fd2dda56cf

pada functional programming, error handling pada async task biasa menggunakan result. result ini ada di swift karena kombinasi enum and generics pada swift sangatlah _powerful_.

Ini bukanlah hal baru pada Swift 2.0, kita sudah bisa menggunakan kekuatan enumeration sejak versi pertama dari Swift.
Dulu enum terbatas sehingga harus pakai box : http://natashatherobot.com/swift-generics-box. Namun swift 2.0 sudah tidak perlu memerlukannya lagi.

Berikut sintaks result

```swift
enum Result<T, Error: ErrorType> {
    case Success(T)
    case Failure(Error)
}
```

Mudahnya, result adalah tipe yang punya dua opsi, yaitu sukses yang berisi sebuah tipe (dalam hal ini bisa apa saja), atau error yang berisi tipe error.

Sebelum melihat penerapan result pada async call, kita coba lihat kode objective-c yang umum kita gunakan untuk membuat network call. Perhatikan parameter dari completion block-nya.

```objc
// SongkickAPI.h
+ (NSURLSessionDataTask *)searchArtist:(NSString *)name
    page:(NSUInteger)page
    completion:(void (^)(NSArray *results, NSError *error))completion;

// SearchViewController.m
- (void)searchButtonClicked {
  NSURLSessionDataTask *task =
  [SongkickAPI
   searchArtist:@"Bad"
   page:1
   completion:^(NSArray *results, NSError *error) {
      if (error) {
        // penanganan error
      }
      // parsing results menjadi daftar artis
  }];
}
```

Penjelasan kenapa parameter results + error jelek dan tidak masuk logika.

Kita lihat pada Swift

```swift
class func searchArtist(
  name: String,
  page: Int = 1,
  completionHandler: (Result<[Artist], ErrorType>) -> Void
)
```

## Akses Privat untuk Unit Test

Seringkali kita mengekspos kelas atau method kita yang sebenarnya private menjadi publik hanya untuk bisa di test di unit test kita. Sekarang di Swift 2.0, tidak perlu lagi kita memodifikasi kode hanya untuk supaya bisa dites. Biarkan saja kode kita apa adanya, lalu gunakan `@testable` pada unit test kita.

```swift
// Tests.swift
import XCTest
@testable  // nama modul kita

// tes dapat akses pada kelas dan method privat!
```

Panduan lebih mudahnya bisa dilihat di blognya [Natasha](http://natashatherobot.com/swift-2-xcode-7-unit-testing-access).

## Jumlah Baris pada Kode
Jumlah baris kode bukanlah metrik penentu kualitas sebuah kode, namun untuk mencari metrik yang sederhana maka akan tetap saya gunakan. Menulis kode Swift harus lebih terinci karena sifatnya _type safety_, walau begitu jumlah baris kodenya lebih sedikit dibanding Objective-C.

Untuk menghitung jumlah baris kode, kita bisa menggunakan perintah `find` dari terminal:

```sh
$ find . \( -iname \*.m -o -iname \*.h -o -iname \*.swift \) -exec wc -l '{}' \+
```

Kode Objective-C

* total +-1370 baris
* dua file yang melebihi 200 baris, yaitu sebuah kelas `ViewController` dan kelas Networking untuk API.

Kode Swift [^1]

* total +-980 baris
* maksimal jumlah baris untuk sebuah file : 145 baris untuk sebuah kelas `ViewController`

Menggunakan Swift memang membuat kode menjadi lebih ramping. Sintaks Swift terlihat lebih sederhana dan lebih nyaman dilihat. Tidak ada detil rumit yang tidak perlu, seperti bintang untuk _pointer_, dua bintang untuk passing `NSError` dan titik koma pada akhir baris.

Compiler Swift juga pintar dalam menyimpulkan tipe data. Sehingga kita tidak perlu menulis secara gamblang semua tipe variabel atau fungsi seperti yang kita lakukan di Objective-C.

Terakhir, saya menggunakan "`class extension`" pada kelas-kelas berbeda sehingga saya bisa memisahkan tanggung jawab dari satu kelas ke beberapa file terpisah.

## Limitation

UI testing masih suka crash dan rusak2, terutama kalau klik2 dengan cepat

Tooling masih suka crash, walau sudah jauh lebih baik dari sebelumnya. yang saya sayangkan fitur playground yang masih sangat fragile. Saya sering suka membuka playground untuk mengecek kebenaran ide di kepala saya  sebelum digabungkan di aplikasi utama. Namun apa daya karena suka crash akhirnya saya koding langsung di aplikasi utama.

## Penutup

Ini adalah waktu yang exciting untuk menjadi Swift developer. kenapa?

Fitur-fitur bahasa ini masih akan terus berubah dan berkembang.


[^1]: Saya sedikit curang karena saya menggunakan library pemilahan JSON, [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON), yang tidak saya masukkan dalam perhitungan baris. Pemilahan data JSON yang sederhana sekalipun masih ribet dan memang masih menjadi topik hangat di komunitas Swift.
