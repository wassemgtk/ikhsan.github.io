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
