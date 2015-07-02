---
title: First Impressions on Porting Objective-C Code to Swift
date: 2015-06-28 16:17 UTC
tags: objective-c, swift
---

After seeing WWDC videos in the past 2 weeks, I felt it's time to dive in trying to learn and use the new shiny features on Xcode 7 and Swift 2.0. I tried to port a year-old prototype of a simple app which I made for [Songkick](https://songkick.com)'s coding test. READMORE I called it __On Tour__, the main idea is to stalk your favorite bands by seeing their tour routes in the map.

![On Tour](blog/2015-06-28-porting-mini-project-objc-to-swift/ontour.gif)

I have put several notes and impression regarding my experience porting the Objective-C code base to Swift.

## Error Handling
Several new features in Swift are designed to better us on handling error cases. Few features that we will review are, Optionals, Guard, Throws and Result Type.

### Optional
Implicitly, all Objective-C objetcs are optionals all along. Because pointer to object either pointing to an instance, but it could also be nil.

This is a snippet of `Artist` class which I wrote on Objective-C

```objc
// Artist.h
@interface Artist : NSObject
@property (nonatomic, strong) NSNumber *artistID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSDate *onDateTour;
@end
```

Just from seeing the headers, it is not clear which properties are required for an instance of the class. Objective-C even allows us to create an `Artist` object without bothering setting its properties. Consequently, it forces us to be extra careful on creating and managing classes and instances. All the logics are our responsibility because Objective-C's compiler is not smart enough to help us out.

Now let's compare the same class in Swift

```swift
// Artist.Swift
class Artist {
  var id: String
  var name: String
  var onTourDate: NSDate?
}
```

By looking to the above snippet, Swift will guarantee that an instance of `Artist` will always have an `id` and a `name`. The only optional property of an `Artist` is `onTourDate`. This rule do makes sense right?. An artist must have a name and unique identifier in the system. But, the artist might not have any tour dates, say because he/she is currently working on an album.

In this case, we even can't create an `Artist`'s instance without having an `id` and a `name`, otherwise the compiler will warn us. And that is a good thing. Compared to Objective-C, Swift and its Optionals helps us even further on modelling real-world objects.

### Guard
Swift 2.0 introduced a new feature called __Guard__. I use 'early exit' pattern whenever I can (some say it "bouncer pattern") for handling errors. I prefer early exit because it advises me to think error cases early on inside my code block. Another reason is indentation, it keeps the happy path in the first level of indentation and avoids pyramids of doom.

```swift
// ArtistViewController.swift

var artist: Artist?

func openArtist() {
  // you could also unwrap optional with guard
  guard let a = artist else {
    return
  }
  openArtist(a)
}
```

### Throws

Swift 2.0 proposed a default way of error handling, __Throws__. Java programmers are familiar with exceptions (`try/catch`), but Swift has a slightly twist, `do/try/catch`. Even in the latest Apple's SDK, methods that might return errors are not using inout parameters anymore (remember `NSError **error`?).

Lets see how we usually do it in Objective-C, with a sample case of converting `NSData` to `NSDictionary`

```objc
// header.h
+ (id)JSONObjectWithData:(NSData *)data options:(NSJSONReadingOptions)opt error:(NSError **)error;

// implementation.h
- (void)convertData:(NSData *)data {
  NSError *error = nil;
  id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:error];
  if (error) {
    // handle the error
    return;
  }
  // using the result
}
```

Whereas in Swift 2.0, calling the same method is easier in the eye, and we also presented with a different code block to handle the error.

```swift
// header.swift
class func JSONObjectWithData(data: NSData, options opt: NSJSONReadingOptions) throws -> AnyObject

// implementation.swift
func convertData(data: NSData) {
  do {
    let result = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! [String: AnyObject]
    // using the result
  } catch {
    // handle the error
  }
}
```

### Enum + Generics = Result

Unfortunately, throws is not suitable to all situation. Throws is a perfect fit for synchronous tasks, but not so much for asynchronous task, such as network call.

Throws will be a problem if we call it from inside a closure, because the error is sent to the closure itself not our calling function. The compiler will warn you saying that there's a type mismatch, because the closure's declaration doesn't have throws but in implementation it does. Nick Lockwood had a great writeup on this problem more in depth (look at the second point), [Thoughts on Swift 2 Errors](https://gist.github.com/nicklockwood/21495c2015fd2dda56cf).

Even Apple has not yet adopting throws for their asynchronous methods. They still pass the error object as a parameter in the completion handler instead using throws (for example see [`dataTaskWithRequest: completionHandler:`](https://developer.apple.com/library/prerelease/ios/documentation/Foundation/Reference/NSURLSession_class/index.html#//apple_ref/occ/instm/NSURLSession/dataTaskWithRequest:completionHandler:)).

What are the alternatives then? In functional programming, error cases are being handled with a special type, Result type. Thanks to enum and generics, we could combine those and implement Result type in Swift. This is how you declare a Result type :

```swift
enum Result<T, Error: ErrorType> {
    case Success(T)
    case Failure(Error)
}
```
It might not make sense in a glance, but the concept is simple. Result only has two possibilities, success and failure. If success, then we should have a value of any type (symbolised by the letter T), whereas if fail then you would have the error object containing the error information.

Before we look at the application for asynchronous task, let's step back to this Objective-C code that we all wrote before when doing network calls. Pay attention on the completion block's parameters.

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
Lets review why using two parameters in the completion block is an incorrect logic. For this case, there are 4 possibilities; (results, nil), (nil, error), (results, error), (nil, nil). From four there are two cases that does not make any sense. We could pass both valid value for results and error, or pass nil for both results and error. These two cases are valid by compiler's eye, although it's illogical.

Now lets tackle this in Swift by applying Result

```swift
// SongkickAPI.swift
class func searchArtist(
  name: String,
  page: Int = 1, // in swift we can declare default value
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

With Result, the solution is much better and does make more sense. Now we only have one parameter for our completion handler. We only have two possibilities, either success which yields us the artists, or failure which sends us the error information. I'm really pleased with this approach, because it makes the code cleaner, clearer and more correct.

## Private Access for Unit Tests

We all know the hassle of exposing our private classes or methods solely for testing. Yes it's feasible using techniques like overriding, using category or swizzling but I find that pretty hacky and inelegant. In Swift 2.0 we could leave our private methods and classes as is, and use `@testable` in our unit tests instead 🎉.

```swift
// Tests.swift
import XCTest
@testable <module name>

// here unit tests have access to private stuff
```
Check Natasha's step-by-step guide on her [blogpost](http://natashatherobot.com/swift-2-xcode-7-unit-testing-access).

## Lines of Code (LOC)

Lets use a simple code metric, lines of code. Although Swift is a type safety language but it doesn't mean that the code is longer and more verbose than Objective-C code.

To count the code's lines, we can use `find` from terminal:

```sh
$ find . \( -iname \*.m -o -iname \*.h -o -iname \*.swift \) -exec wc -l '{}' \+
```

__Objective-C Code__

* +-1370 lines
* two files (a `ViewController` and Networking class) exceed 200 lines

__Swift Code__ [^1]

* +-980 lines
* longest file is a `ViewController` class with 145 lines of code

Using Swift makes our codebase leaner and more compact. Its syntax is simpler and easier in the eye. No more details to make the compiler happy (star sign for _pointers_, semicolons, etc). Its compiler are smarter because it could infer data types, so we don't need to declare types in every variables like we do in Objective-C.

## Drawbacks

I tried using UI Testing for this project, but it doesn't perform as I expected. Using it in Xcode 7b2, it's still fragile and prone to crash, especially when you do stress test by doing fast taps. Nevertheless, this feature is really promising and I hope it will be more robust and stable in the near future.

Although Playground is much more stable, still the SourceKit crash rate is quite high. Sometimes I experiment in Playground first before I put the code inside the main project. Sadly, the crashes popped up quite often, hence I prefer to code directly inside my main app.

## Conclussion

This is an exciting time to be a Swift developer. The language felt more modern and complete than Objective-C, it's proven by the examples I shared above. Even more, Swift will keep changing and evolving with its community. Don't forget that later this year, Swift will be open source and will run on Linux. I can't wait to write sites and apps with Swift!

Browse the code if you're interested,  [On Tour](https://github.com/ikhsan/On-Tour).

Thanks for reading!

[^1]: Bit of cheating here because I use JSON parsing library, [SwiftyJSON](https://github.com/SwiftyJSON/SwiftyJSON), which I don't include in the line counting. Even simple JSON parsing is not that straight forward in Swift and still is a hot topic in Swfit community.
