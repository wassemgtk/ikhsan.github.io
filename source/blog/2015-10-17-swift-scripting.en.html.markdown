---
title: "Swift Scripting : Extracting String File"
date: 2015-10-17 22:48 UTC
tags: swift, scripting
---

I was given a tedious task at work that to extract all the strings from `"Localizable.strings"` in our iOS project to an excel spreadsheet. I was wondering how to make this more interesting and more challenging. So I took this task to be another opportunity to play around with Swift. READMORE

I was inspired by Ayaka's talk on Swift Summit that even though you have not yet used Swift for the main project, we could tackel small problems with Swift.

### Making and Running Swift Script

* Make sure Xcode is installed
* Create a swift file (mine is '`xtractr.swift`')
* Add [shebang](https://en.wikipedia.org/wiki/Shebang_(Unix)) notation in the first line of the file to inform that we will compile the file with Swift REPL

```swift
#!/usr/bin/env xcrun swift
```

* Use `print()` to print text on your console

```swift
print("This text is created with Swift!")
```

* On your terminal, change your file permission to be executable

```sh
// make sure you are in the same directory as your swift file
$ chmod +x xtractr.swift
```

* Run your script from your terminal

```sh
$ ./xtractr.swift
"This text is created with Swift!"
```

Simple right? After we have successfully print a text, lets try build our real parser for `Localizable.strings`

### Reading arguments from terminal

To receive the filename from terminal, we could use a variable called `Process.arguments`. This variable has all the arguments
that is added when the app is called.

Try to change our script so that it prints all the arguments

```swift
#!/usr/bin/env xcrun swift
print(Process.arguments)
```

Now run the script with some arguments

```sh
$ ./xtractr.swift test arguments 123
["./xtractr.swift", "test", "arguments", "123"]
```
As we can see, each word is included in the list (which also includes the filename itself). We want to create a script that expects only one parameter, which is the path to a strings file. We could tidy this ability to its own function, which could also checks the total of parameters and uses the first one as its path.

```swift
#!/usr/bin/env xcrun swift

func getParameter() -> String {
    guard Process.arguments.count >= 2 else {
        return "File is not found"
    }
    return Process.arguments[1]
}

print(getParameter())
```

Before you continue on testing the script, try to find any `Localizable.strings` that you have and put inside the same directory as the script (I put mine in `~/Desktop`). Run the script again without an argument, one argument and multiple arguments.


```sh
$ ./xtractr.swift     
File is not found
$ ./xtractr.swift Localizable.strings
Localizable.strings
$ ./xtractr.swift Localizable.strings 123 heyho
Localizable.strings
```

### Reading contents from file

Untuk membaca konten teks dari sebuah file, kita bisa gunakan fungsi konstruktor dari `NSString` yang menerima parameter filepath dan encoding.

```swift
let content = try NSString(contentsOfFile: filepath, encoding: NSUTF8StringEncoding)
```

Bisa kita periksa bahwa tipe yang digunakan adalah `NSString` dan bukan `String` dari Swift. Kita bisa konversi dari tipe satu ke tipe lainnya, namun karena kita menggunakan beberapa perilaku dan method dari `NSString` maka kita biarkan dulu dan konversi ke `String` hanya saat diperlukan.

### Mengurai teks dari `Localizable.strings`

Penguraian akan menggunakan `NSRegularExpression` yang akan menemukan semua string dalam file yang berformat : `"<key>" = "<value>";`.

```swift
let regex = try NSRegularExpression(pattern: "\"(.+?)\"\\s*=\\s*\"(.+?)\"\\s*;", options: .CaseInsensitive)
let matches = regex.matchesInString((query as String), options: .WithTransparentBounds, range: NSMakeRange(0, query.length))
```

Variable `matches` akan berisi array dari objek `NSTextCheckingResult`. `NSTextCheckingResult` mempunyai sebuah list lagi yang berisi `NSRange` yang menunjukan lokasi-lokasi dari string yang cocok dengan format regex yang kita berikan. Untuk mendapatkan semua string yang dari sebuah `NSTextCheckingResult` kita harus mengaksesnya dengan `rangeAtIndex`

```swift
var strings = [String]()
for index in 0..<(match.numberOfRanges) {
    let range = match.rangeAtIndex(index)
    strings.append(query.substringWithRange(range) as String)
}
return strings
```

Setiap array string yang kita dapatkan akan berjumlah tiga, yaitu dalam kesatuan format `"<key>" = "<value>";`, `<key>` dan terakhir `<value>`. Kita hanya akan menggunakan 2 string terakhir dari setiap array string kita.

Terakhir kita akan mengkonversi semua pasangan <key, value> kita ke dalam format yang bisa dibaca excel. Format yang paling mudah adalah format csv atau comma separated value. Intinya tiap kolom akan dipisahkan dengan koma; "`<key>,<value>\n`"

Bila kita gabung seluruh proses ini menjadi satu kesatuan, funsi pengurai akan terlihat seperti berikut

```swift
func parse(query: NSString) throws -> String {
    let regex = try NSRegularExpression(pattern: "\"(.+?)\"\\s*=\\s*\"(.+?)\"\\s*;", options: .CaseInsensitive)
    let matches = regex.matchesInString((query as String), options: .WithTransparentBounds, range: NSMakeRange(0, query.length))

    let results = matches

        // transformasi dari NSTextCheckingResult menjadi array String
        .map { match -> [String] in
            var strings = [String]()
            for index in 0..<(match.numberOfRanges) {
                let range = match.rangeAtIndex(index)
                strings.append(query.substringWithRange(range) as String)
            }
            return strings
        }

        // periksa apakah pasti ada tiga atau lebih string
        .filter { $0.count >= 3 }

        // transformasi dari array string menjadi key value yang terpisah oleh koma
        .reduce("") { (initial, strings) -> String in
            return initial + "\(strings[1]),\(strings[2])\n"
        }

    return results
}
```

### Hasil akhir

Kode akhir bisa lihat di [sini](2015-10-17-swift-scripting/xtractr.swift), berikut dengan penanganan error yang lebih lengkap.

Namun saat kita jalankan, skrip ini hanya akan menampikan konten csv di dalam terminal. Untuk menyimpannya ke dalam file, kita harus pass hasil cetak tersebut langsung di terminal dengan format "` > nama_file.csv`".

```sh
$ ./xtractr.swift Localizable.strings # hanya mencetak di terminal
$ ./xtractr.swift Localizable.strings > extracted.csv # mencetak ke dalam sebuah file extracted.csv
```

Walau tugas saya saat itu cukup remeh namun tugas ini jadi lebih menarik dan lebih menyenangkan karena saya menantang diri saya dengan menggunakan Swift. Sampai jumpa di skrip-skrip Swift selanjutnya!
