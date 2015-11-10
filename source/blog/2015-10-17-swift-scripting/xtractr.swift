#!/usr/bin/env xcrun swift

import Foundation

enum StringerError: ErrorType {
    case NoFileSpecified
    case FileNotFound(filepath: String)
    case ParsingFailed
}

func getArgument() throws -> String {
    guard Process.arguments.count >= 2 else {
        throw StringerError.NoFileSpecified
    }
    return Process.arguments[1]
}

func contentFromFile(filename: String) throws -> NSString {
    let filepath = "\(NSFileManager.defaultManager().currentDirectoryPath)/\(filename)"

    guard NSFileManager.defaultManager().fileExistsAtPath(filepath) else {
        throw StringerError.FileNotFound(filepath: filepath)
    }

    return try NSString(contentsOfFile: filepath, encoding: NSUTF8StringEncoding)
}

func parse(query: NSString) throws -> String {
    let regex = try NSRegularExpression(pattern: "\"(.+?)\"\\s*=\\s*\"(.+?)\"\\s*;", options: .CaseInsensitive)
    let matches = regex.matchesInString((query as String), options: .WithTransparentBounds, range: NSMakeRange(0, query.length))

    let results = matches
        .map { match -> [String] in
            var strings = [String]()
            for index in 0..<(match.numberOfRanges) {
                let range = match.rangeAtIndex(index)
                strings.append(query.substringWithRange(range) as String)
            }
            return strings
        }
        .filter { $0.count >= 3 }
        .reduce("") { (initial, strings) -> String in
            return initial + "\(strings[1]),\(strings[2])\n"
        }

    return results
}

func main() -> Int {
    do {
        let filename = try getArgument()
        let content = try contentFromFile(filename)
        let result = try parse(content)
        print(result)
        return 1
    } catch StringerError.NoFileSpecified {
        print("Error: file is not specified")
        return 0
    } catch StringerError.FileNotFound(let filepath) {
        print("Error: file \(filepath) is not existed")
        return 0
    } catch StringerError.ParsingFailed {
        print("Error: parsing file failed")
        return 0
    } catch {
        print("Error 😭")
        return 0
    }
}

main()
