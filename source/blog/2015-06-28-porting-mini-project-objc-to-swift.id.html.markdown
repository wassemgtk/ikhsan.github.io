---
title: Kesan Pertama Mengubah Kode dari Objective-C ke Swift
date: 2015-06-28 16:18 UTC
tags: objective-c, swift
---

Setelah melihat beberapa video WWDC dalam 2 minggu terakhir, saya akhirnya mencoba fitur-fitur baru dari xcode 7 dan Swift. Sekedar iseng-iseng, saya menggunakan prototipe aplikasi sederhana yang saya buat tahun lalu untuk coding test dari [Songkick](https://api.songkick.com). READMORE Saya namakan "__On Tour__", ide dasar aplikasinya adalah untuk melihat jalur tur band-band kesayangan kita di peta.

![On Tour](blog/2015-06-28-porting-mini-project-objc-to-swift/ontour.gif)

Berikut adalah beberapa catatan dan kesan saya saat mencoba menulis ulang basis kode dari Objective-C ke Swift 2.0.

## Penanganan Error
Fitur-fitur bahasa Swift menurut saya sengaja dirancang agar kita memikirkan lebih seksama dengan penanganan error. Beberapa diantaranya adalah Optional, Guard, Throws dan Result.

### Optional
Secara implisit seluruh objek yang kita buat dalam Objective-C adalah Optionals. Karena objek selain punya nilai, tapi bisa juga tidak (atau nil).

Lihat cuplikan kelas `Artist` yang saya tulis untuk Objective-C;

```objc
// Artist.h
@interface Artist : NSObject
@property (nonatomic, strong) NSNumber *artistID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *onDateTour;
@end
```

Tidak jelas terlihat dari ketiga properti, mana yang harus dipunyai seorang artis dan mana yang tidak. Bahkan kita bisa saja membuat sebuah objek artis tanpa properti sama sekali. Ini memaksa kita untuk ekstra hati-hati dalam mengolah sebuah kelas, karena compiler tidak punya pengetahuan terlalu jauh dan seluruh logika akan berada sepenuhnya di tangan developer.

Sekarang kita lihat kelas sama yang ditulis dengan Swift;

```swift
// Artist.swift
class Artist {
  var id: String
  var name: String
  var onTourDate: NSDate?
}
```
Dalam cuplikan kode di atas, Swift akan menjamin bahwa properti `id` dan `name` akan selalu ada di sebuah objek `Artist`. Satu-satunya properti yang mungkin tidak dipunyai seorang `Artist` adalah `onTourDate`. Kita bahkan tidak bisa lagi membuat objek artis tanpa `id` dan `nama`, karena compiler akan selalu mengingatkan kita.

Kalau dipikir-pikir masuk akal toh? Artis kan pasti punya nama, dan juga pasti punya identifikasi dalam sistem. Namun, bisa saja seorang artis tidak punya jadwal tur karena sedang sibuk menggarap album. Dibandingkan Objective-C, Swift dan Optional-nya dapat membantu kita lebih jauh dalam memodelkan dan melogikakan objek di kehidupan nyata.

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

### Enum + Generics = Result

Sayangnya throws bukanlah cara penanganan error yang cocok untuk segala situasi. Throws mudah digunakan untuk pekerjaan yang synchronous, tapi sulit diterapkan di pekerjaan asynchronous seperti pengambilan data dari network.

Throws akan bermasalah bila kita panggil dari dalam closure, karena yang akan menerima 'lemparan'-nya adalah si closure itu sendiri, bukan fungsi yang memanggilnya. Compiler akan mengingatkan kita kalau tipe closure tidak cocok, karena deklarasinya tanpa throws tapi diimplementasinya menggunakan throws. Lebih lengkapnya, Nick Lockwood menulis pemikirannya tentang hal ini di poin #2 pada tulisannya, [Thoughts on Swift 2 Errors](https://gist.github.com/nicklockwood/21495c2015fd2dda56cf).

Bahkan kalau kita tilik kembali SDK terakhir dari Apple, method mengembalikan data secara asynchronous tetap mempunyai error sebagai parameternya (sebagai contoh, lihat [`dataTaskWithRequest: completionHandler:`](https://developer.apple.com/library/prerelease/ios/documentation/Foundation/Reference/NSURLSession_class/index.html#//apple_ref/occ/instm/NSURLSession/dataTaskWithRequest:completionHandler:) ). Bahkan Apple pun belum menggunakan throws untuk method yang asynchronous.

Lalu apa alternatif lain yang lebih cocok? Pada functional programming, error handling pada async task biasa menggunakan sebuah tipe khusus, Result. Result ini bisa kita gunakan di swift dengan mengkombinasikan enum and generics. Berikut sintaks dari tipe Result :

```swift
enum Result<T, Error: ErrorType> {
    case Success(T)
    case Failure(Error)
}
```

Mudahnya, Result adalah tipe yang punya dua kemungkinan, yaitu sukses atau gagal. Kalau sukses Result berisi sebuah tipe apapun (disimbolkan dengan huruf T), sedangkan kalau gagal Result berisi error.

Sebelum melihat penerapan result pada pekerjaan yang asynchronous, kita lihat dulu kode Objective-C yang umum kita gunakan saat memanggil data dari jaringan. Perhatikan parameter dari completion block-nya.

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
        return
      }
      // penggunaan artis terlacak
  }];
}
```

Kita telaah kenapa menggunakan dua parameter untuk completion block kurang baik. Pada kasus di atas, ada 4 kemungkinan yang terjadi; (results, nil), (nil, error), (results, error), (nil, nil). Dari empat, dua diantaranya tidak masuk di akal. Kita bisa saja berikan results dan error yang tidak nil, atau results dan error yang sama-sama nil. Dua kemungkinan ini __valid__ di mata compiler, padahal tidak masuk logika.

Sekarang kita bandingkan dengan Swift + Result

```swift
// SongkickAPI.swift
class func searchArtist(
  name: String,
  page: Int = 1,
  completionHandler: (Result<[Artist], ErrorType>) -> NSURLSessionDataTask
)

// SearchViewController.swift
func buttonClicked() {
  let task = SongkickAPI.searchArtist("Bad") { result in
    switch result {
    case .Success(let artists):
      // penggunaan artis terlacak
    case .Failure(let error):
      // penanganan error
    }
  }
}

```
Dengan Result, ini lebih bagus dan lebih masuk diakal. Paramater pada completion handler cukup satu saja. Kemungkinannya hanya dua, sukses berarti yang memberikan daftar artis, atau gagal yang memberikan informasi kegagalan pada error. Untuk kasus ini, saya puas menggunakan Result karena kode mjadi lebih bersih, lebih jelas dan lebih benar.

## Akses Privat untuk Unit Test

Seringkali kita mengekspos kelas atau method kita yang sebenarnya private menjadi publik hanya untuk bisa di test di unit test kita. Sekarang di Swift 2.0, tidak perlu lagi kita memodifikasi kode hanya untuk supaya bisa dites. Biarkan saja kode kita apa adanya, lalu gunakan `@testable` pada unit test kita.

```swift
// Tests.swift
import XCTest
@testable  // nama modul kita

// tes dapat akses pada kelas dan method privat
```

Panduan lebih mudahnya bisa dilihat di blognya [Natasha](http://natashatherobot.com/swift-2-xcode-7-unit-testing-access).

## Jumlah Baris pada Kode
Jumlah baris kode bukanlah metrik penentu kualitas sebuah kode, namun untuk mencari metrik yang sederhana maka akan tetap saya gunakan. Menulis kode Swift harus lebih terinci karena sifatnya _type safety_, walau begitu jumlah baris kodenya lebih sedikit dibanding Objective-C.

Untuk menghitung jumlah baris kode, kita bisa menggunakan perintah `find` dari terminal:

```sh
$ find . \( -iname \*.m -o -iname \*.h -o -iname \*.swift \) -exec wc -l '{}' \+
```

__Kode Objective-C__

* total +-1370 baris
* dua file yang melebihi 200 baris, yaitu sebuah kelas `ViewController` dan kelas Networking untuk API.

__Kode Swift__ [^1]

* total +-980 baris
* maksimal jumlah baris untuk sebuah file : 145 baris untuk sebuah kelas `ViewController`

Menggunakan Swift memang membuat kode menjadi lebih ramping. Sintaks Swift terlihat lebih sederhana dan lebih nyaman dilihat. Tidak ada detil rumit yang tidak perlu, seperti bintang untuk _pointer_, dua bintang untuk passing `NSError` dan titik koma pada akhir baris.

Compiler Swift juga pintar dalam menyimpulkan tipe data. Sehingga kita tidak perlu menulis secara gamblang semua tipe variabel atau fungsi seperti yang kita lakukan di Objective-C.

Terakhir, saya menggunakan `extension` pada kelas-kelas berbeda sehingga saya bisa memisahkan tanggung jawab dari satu kelas ke beberapa file terpisah.

## Kelemahan

Saya sempet mencoba menggunakan UI Testing untuk aplikasi ini, namun ternyata performanya tidak sebagus yang terlihat di keynote. UI Testing pada Xcode 7b2 masih mudah crash, terutama bila kita gunakan aplikasi kita secara cepat. Tapi fitur ini sangat menjanjikan dan semoga bisa lebih robust dan stabil ke depannya.

Begitu juga dengan fitur Playground. Seringkali saya memulai mencoba apa yang ada di kepala Playground terlebih dahulu, bila terbukti berhasil baru saya kopas ke dalam proyek utama. Namun apa daya Playground masih suka crash dan akhirnya saya koding langsung kembali di proyek utama.

## Penutup

Ini adalah waktu yang bergairah untuk menjadi Swift developer. Bahasanya jauh lebih modern dan lebih lengkap daripada Objective-C, bisa dilihat dari contoh-contoh di atas yang saya alami. Apalagi fitur-fitur bahasa ini masih akan terus berubah dan berkembang. Jangan lupa, akhir tahun Swift akan jadi open source dan bisa dijalankan di Linux. Saya tidak sabar untuk bisa membuat website dan aplikasi dengan Swift!

Bila tertarik untuk mengecek proyek utuhnya silahkan lihat repositorynya, [On Tour](https://github.com/ikhsan/On-Tour).

Makasih ya sudah membaca!


[^1]: Saya sedikit curang karena saya menggunakan library pemilahan JSON, [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON), yang tidak saya masukkan dalam perhitungan baris. Pemilahan data JSON yang sederhana sekalipun masih ribet dan memang masih menjadi topik hangat di komunitas Swift.
