---
title: Kesan Pertama Mengubah Kode dari Objective-C ke Swift
date: 2015-06-28 16:18 UTC
tags: objective-c, swift
---

Setelah melihat beberapa video WWDC dalam 2 minggu terakhir, saya akhirnya mencoba fitur-fitur baru dari xcode 7 dan swift. Sekedar iseng-iseng, saya menggunakan program sederhana yang saya buat tahun lalu untuk coding test dari [Songkick](https://songkick.com). Saya namakan "__On Tour__", ide dasar aplikasinya adalah untuk melihat jalur tur band-band kesayangan di peta.

Berikut adalah beberapa catatan dan kesan saya saat mencoba menulis ulang program mainan saya dari objective-c ke swift 2.0.

## Type Safety
Menurut saya ini adalah jawaban utama pada pertanyaan 'kenapa harus pindah ke swift'. Kita pasti sering mendapatkan crash karena kita tidak memanggil nil objek, atau misalnya kita casting objek yang tidak tepat. Pada Objective-C, kesalahan macam ini tidak bisa ditangkap pada saat compile time, sehingga kita kena getahnya pada saat runtime (alias crash).

Untungnya pada Swift, bahasa ini memaksa kita untuk lebih berhati-hati lagi. Kita lihat cuplikan dua kode dari On Tour;

Ini hanya contoh kecil dari Type Safety, namun semakin sering menggunakannya saya semakin suka dengan Swift yang lebih strict.

## Enumeration dan Generics

Kombinasi swift enumeration and generics sangatlah powerful.

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
Fitur bahasa yang memaksa kita untuk memikirkan lebih seksama dengan error handling, seperti optional, guard, throw.

## Sintaks
Walaupun swift terasa lebih verbose karena error handling dan type safety memaksa kita lebih rinci dalam ngoding, tapi ternyata kode yang saya hasilkan lebih sedikit. Saya hitung baris kode pada dua aplikasi yang sama, di proyek Objective-C terdapat xxx baris sedangkan di Swift hanya xxx baris.

Memang saya menggunakan satu library untuk parsing JSON (karena parsing JSON tanpa library terlihat sangat ribet), namun umumnya jumlah kode akan berkurang.

## Limitation

UI testing masih suka crash dan rusak2, terutama kalau klik2 dengan cepat

Tooling masih suka crash, walau sudah jauh lebih baik dari sebelumnya. yang saya sayangkan fitur playground yang masih sangat fragile. Saya sering suka membuka playground untuk mengecek kebenaran ide di kepala saya  sebelum digabungkan di aplikasi utama. Namun apa daya karena suka crash akhirnya saya koding langsung di aplikasi utama.

# Kesimpulan

Ini adalah waktu yang exciting untuk menjadi Swift developer. Serunya lagi, fitur-fitur bahasa ini masih akan terus berubah dan berkembang.
