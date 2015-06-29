---
title: Kesan Pertama Mengubah Kode dari Objective-C ke Swift
date: 2015-06-28 16:18 UTC
tags: objective-c, swift
---

Setelah melihat beberapa video wwdc dalam 2 minggu terakhir, saya akhirnya mencoba fitur-fitur baru dari xcode 7 dan swift[^1]. Sekedar iseng-iseng, saya menggunakan program sederhana yang saya buat tahun lalu untuk coding test untuk Songkick. Inti aplikasinya adalah untuk melihat jalur tur band-band kesayangan di peta.

Berikut adalah beberapa catatan dan kesan saya saat mencoba menulis ulang program mainan saya dari objective-c ke swift 2.0.

## Type Safety
Menurut saya ini adalah jawaban utama pada pertanyaan 'kenapa pindah ke swift'.

## Enumeration + Generics
Result cocok untuk asynchronous result.

```swift
enum Result<T, Error: ErrorType> {
    case Success(T)
    case Failure(Error)
}
```

Coba bandingkan method-method ini. Perhatikan value type parameternya.

```objective-c
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

## Error Handling
Fitur bahasa yang memaksa kita untuk memikirkan lebih seksama dengan error handling, seperti optional, guard, throw,

## Sintaks
Saya hitung baris kode pada dua aplikasi yang sama, di proyek Objective-C terdapat xxx baris sedangkan di Swift hanya xxx baris. Memang saya menggunakan satu library untuk parsing JSON (karena parsing JSON tanpa library terlihat sangat ribet), namun umumnya jumlah kode akan berkurang.




[^1]: Beberapa video WWDC yang saya rekomendasikan: [a](http://google.com), [b](http://google.com), [c](http://google.com)
