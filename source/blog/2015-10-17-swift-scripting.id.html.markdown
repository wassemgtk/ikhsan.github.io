---
title: "Skrip dengan Swift : Ekstraksi Berkas String"
date: 2015-10-17 22:48 UTC
tags: swift, scripting
---

Belum lama, saya diberikan tugas di kantor untuk mengekstraksi kopi di `"Localizable.strings"` ke format excel. Pikir saya ini agak membosankan bila mengerjakan tugas ini dengan cara manual. Maka, saya pikir ini adalah sebuah kesempatan untuk kembali menggunakan Swift. READMORE

Terilhami dari presentasi dari [Ayaka di Swift Summit](https://realm.io/news/swift-scripting/), tiap tugas kecil seperti ini bisa lho dikerjakan dengan Swift. Intinya, walaupun belum ada kode Swift dalam proyek utama kita bukan berarti kita tidak bisa menggunakan Swift sama sekali.

### Membuat dan Menjalankan Skrip dengan Swift

* Pastikan Xcode sudah ter-install
* Buat file Swift (saya namakan `xtractr.swift`) seperti berikut

```swift
#!/usr/bin/env xcrun swift
print("Teks ini dibuat dengan Swift!")
```

* Di terminal, ganti file permission menjadi executable

```sh
// dengan asumsi sedang berada di direktorinya xtractr.swift
$ chmod +x xtractr.swift
```

* Jalankan skrip dari terminal

```sh
$ ./xtractr.swift
"Teks ini dibuat dengan Swift!"
```

Cukup mudah kan? Setelah hanya menampilkan contoh teks, mari kita buat pengurai `Localizable.strings` yang sebenarnya.

### Membaca parameter dari terminal

Untuk mendapatkan nama file dari terminal, kita bisa gunakan variabel `Process.arguments`. Variabel ini berisi semua kata yang diketikkan saat dijalankan dari terminal.

Silahkan ganti perintah cetak teks kita menjadi cetak parameter-parameter. File skrip kita akan menjadi seperti ini;

```swift
#!/usr/bin/env xcrun swift
print(Process.arguments)
```

Jalankan kembali di terminal

```sh
$ ./xtractr.swift tes argumen 123
["./xtractr.swift", "tes", "argumen", "123"]
```

Bisa kita lihat, kata per kata dirangkum dalam list `Process.arguments` (termasuk nama programmnya sendiri). Skrip kita hanya akan mengharapkan satu buah parameter, yaitu filepath dari file string itu sendiri.

Sehingga kita bisa rangkum menjadi sebuah fungsi tersendiri, yang akan mengecek jumlah parameter dan mengambil parameter pertama sebagai filepath.


```swift
#!/usr/bin/env xcrun swift

func getParameter() -> String {
    guard Process.arguments.count >= 2 else {
        return "File tidak ditemukan"
    }
    return Process.arguments[1]
}

print(getParameter())
```

Sebelum mencoba kembali, kopi suatu file Localizable.strings kita punya ke dalam direktori yang aktif di terminal. Jalankan kembali dengan menggunakan nama file yang benar. Coba cek juga bila tanpa menggunakan parameter, atau menggunakan lebih dari satu parameter.

```sh
$ ./xtractr.swift Localizable.strings
Localizable.strings
$ ./xtractr.swift     
File tidak ditemukan
$ ./xtractr.swift Localizable.strings 123 heyho
Localizable.strings
```

### Membaca teks dari file

```swift
func contentFromFile(filename: String) throws -> NSString {
    let filepath = "\(NSFileManager.defaultManager().currentDirectoryPath)/\(filename)"

    guard NSFileManager.defaultManager().fileExistsAtPath(filepath) else {
        throw StringerError.FileNotFound(filepath: filepath)
    }

    return try NSString(contentsOfFile: filepath, encoding: NSUTF8StringEncoding)
}
```

### Mengurai teks dari Localizable.strings

```swift
func parse(query: NSString) throws -> String {
    let regex = try NSRegularExpression(pattern: "\"(.+?)\"\\s*=\\s*\"(.+?)\"\\s*;", options: .CaseInsensitive)
    let matches = regex.matchesInString((query as String), options: .WithTransparentBounds, range: NSMakeRange(0, query.length))

    let results = matches
        .map { (match) -> [NSRange] in
            var ranges = [NSRange]()
            for index in 0..<(match.numberOfRanges) {
                ranges.append(match.rangeAtIndex(index))
            }
            return ranges
        }
        .filter { $0.count >= 3 }
        .map { ranges -> [String:String] in
            let key = query.substringWithRange(ranges[1]) as String
            let value = query.substringWithRange(ranges[2]) as String
            return [key:value]
        }
        .reduce("") { (initial, keyvalue) -> String in
            guard let key = keyvalue.keys.first, let value = keyvalue.values.first else {
                return ""
            }
            return initial + "\(key),\(value)\n"
        }

    return results
}
```

### Error handling

```swift
enum StringerError: ErrorType {
    case NoFileSpecified
    case FileNotFound(filepath: String)
    case ParsingFailed
}
```

### Hasil akhir

Kode akhir bisa lihat di [sini](https://gist.github.com/ikhsan/4d1f1502bdde5ee90d23). Untuk membukanya, kita harus mencetak hasil uraian dari skrip ke sebuah file dengan format csv. Format ini mudah dimengerti karena hanya berisi tabel yang datanya dipisah oleh koma. Untungnya Excel dapat membuka file csv dan kita bisa save ke dalam format excel biasa.

```sh
$ ./xtractr.swift Localizable.strings # hanya mencetak di terminal
$ ./xtractr.swift Localizable.strings > extracted.csv # mencetak ke dalam sebuah file csv
```

Walau tugas saya saat itu cukup remeh namun tugas ini jadi lebih menarik dan lebih menyenangkan karena saya menantang diri saya dengan menggunakan Swift. Sampai jumpa di edisi membuat skrip dengan Swift selanjutnya!
