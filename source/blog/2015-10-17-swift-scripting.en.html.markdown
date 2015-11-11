---
title: "Swift Scripting : Extracting String File"
date: 2015-10-17 22:48 UTC
tags: swift, scripting
---

I was given a tedious task at work that to extract all the strings from `"Localizable.strings"` in our iOS project to an excel spreadsheet. I was wondering how to make this more interesting and more challenging. So I took this task to be another opportunity to play around with Swift. READMORE

I was inspired by [Ayaka's talk](https://realm.io/news/swift-scripting/) on Swift Summit that even though you have not yet used Swift for the main project, we could tackel small problems with Swift.

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

To read the contents of a file, we could use `NSString`'s constructor method that expects a file path.

```swift
let content = try NSString(contentsOfFile: filepath, encoding: NSUTF8StringEncoding)
```

If we look closely, the type that we use is `NSString` instead of Swift's `String`. We could convert from one type to another quite easily but we just keep using `NSString` because we need its behaviors and methods, and just convert the type once needed.

### Parsing the texts of `Localizable.strings`

Our parser will use `NSRegularExpression` which will find all the strings from the file that match the pattern : `"<key>" = "<value>";`.

```swift
let regex = try NSRegularExpression(pattern: "\"(.+?)\"\\s*=\\s*\"(.+?)\"\\s*;", options: .CaseInsensitive)
let matches = regex.matchesInString((query as String), options: .WithTransparentBounds, range: NSMakeRange(0, query.length))
```

Variable `matches` is an array of `NSTextCheckingResult`. `NSTextCheckingResult` has a list of `NSRange` that refers to locations of all the string that match the pattern that is given. To get all the string from an instance of `NSTextCheckingResult`, we can access it via its `rangeAtIndex` method.

```swift
var strings = [String]()
for index in 0..<(match.numberOfRanges) {
    let range = match.rangeAtIndex(index)
    strings.append(query.substringWithRange(range) as String)
}
return strings
```

Apparently, every array of strings that we receive has a total of three; a format of the whole pattern (`"<key>" = "<value>";`), its key (`<key>`) and last its value (`<value>`). For our purpose, we only need the last two which is the key and value pair.

Lastly, we convert every key-value pair to a format that is readable by Excel. The easiest format is comma-separated values or known as CSV file. The file should simply separate each column with a comma, so for us we need to format our pair to be; "`<key>,<value>\n`"

If we combine all the parsing processes into one, its function would looked like below

```swift
func parse(query: NSString) throws -> String {
    let regex = try NSRegularExpression(pattern: "\"(.+?)\"\\s*=\\s*\"(.+?)\"\\s*;", options: .CaseInsensitive)
    let matches = regex.matchesInString((query as String), options: .WithTransparentBounds, range: NSMakeRange(0, query.length))

    let results = matches

        // transforms NSTextCheckingResult to an array of Strings
        .map { match -> [String] in
            var strings = [String]()
            for index in 0..<(match.numberOfRanges) {
                let range = match.rangeAtIndex(index)
                strings.append(query.substringWithRange(range) as String)
            }
            return strings
        }

        // checks if the Strings is more than three
        .filter { $0.count >= 3 }

        // transforms an array of string into a comma-separated key value pairs
        .reduce("") { (initial, strings) -> String in
            return initial + "\(strings[1]),\(strings[2])\n"
        }

    return results
}
```

### Result

The final code can be reviewed [here](https://github.com/ikhsan/ikhsan.github.io/blob/develop/source/blog/2015-10-17-swift-scripting/xtractr.swift). Also, I have added error handling using custom `ErrorType`s and `guard`s.

Although, this script only prints the csv contents in the terminal instead of making a new file. To put all the csv content to a file, we need to pass it in terminal using this format "` > <file_name>.csv`".

```sh
$ ./xtractr.swift Localizable.strings # only prints in terminal
$ ./xtractr.swift Localizable.strings > extracted.csv # create a new file 'extracted.csv' and put all the contents inside
```
Even though this task is simple, but we made it so that it is more interesting and fun! I challenged myself to use Swift and I really enjoyed it. See you in another Swift scripting posts!

---

## Update 10-11-2015

If you need a more advanced inspiration on Swift scripting, take a look [Ayaka's post](http://swift.ayaka.me/posts/2015/11/5/swift-scripting-generating-acknowledgements-for-cocoapods-and-carthage-dependencies) on making acknowledgement page by reading its Cocoapods and Carthage dependencies. Really neat!
