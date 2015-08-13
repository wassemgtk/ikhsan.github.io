---
title: "Data Visualisation with Swift : The Future of Ramadhan"
date: 2015-08-06 09:24 UTC
tags: swift
---

Fasting in London during Ramadhan made me think about how long should other Muslims around the world fast. Motivated by my own curiosity, [I created a visualisation](http://www.ikhsan.me/post/126462222797/the-future-of-ramadhan) to answer that question. READMORE

This also serves as an opportunity for me to practice Swift. Although using [d3](http://d3js.org) might be the best way for data visualisation, just for the sake of having fun, why don't we use Swift instead.

## Data Collection

### Ramadhan's Dates

First thing that we need to know is the exact dates for future Ramadhan in 25 years time. This could be tackled with `NSCalendar` since the class acknowledges Islamic calendar. By composing dates using `NSDateComponents`, we could easily create Ramadhan dates for many years to come.

```swift
extension NSDate {
    static func rmdn_ramadhanDaysForHijriYear(year: Int) -> [NSDate] {
        guard let hijriCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierIslamic) else {
          return []
        }

        let components = NSDateComponents()
        components.month = 9 // Ramadhan is the 9th month in Islamic calendar
        components.year = year

        // using flatMap instead of map to weed nil values,
        // because dateFromComponents returns an optional NSDate
        return (1..<30).flatMap { day in
            components.day = day
            return hijriCalendar.dateFromComponents(components)
        }
    }
}
```

### Location

We need to know the exact coordinate for cities with only its name. Fortunately, `CoreLocation` has a function that transforms a `String` of city name into an object `CLPlacemark` (also know as _geocoding_).

```swift
CLGeocoder().geocodeAddressString("London") { p, error in
    guard let placemark = p?.first else {
        return
    }

    placemark // a CLPlacemark object containing London's location information
}
```

### Prayer Time

The first thought on finding prayer times is by using external APIs such as [MuslimSalat](http://muslimsalat.com/api/) or [xchanch](http://xhanch.com/xhanch-api-islamic-get-prayer-time/). The disadvantage of this approach is once the API is inaccessible our visualisation will not work. Therefore, we need to minimise our application's dependency to other applications as much as we could.

I use an app called [Guidance](http://guidanceapp.com) for checking prayer times everyday. Luckily, the module for the prayer times calculation is opened by its author. Using [`BAPrayerTimes`](https://github.com/batoulapps/BAPrayerTimes), we can calculate prayer times without making any network calls.


```swift
func prayerTimesForDate(date: NSDate, placemark: CLPlacemark) -> BAPrayerTimes? {
    guard let latitude = placemark.location?.coordinate.latitude,
        let longitude = placemark.location?.coordinate.longitude,
        let timeZone = placemark.timeZone else {
            return nil
    }

    return BAPrayerTimes(
        date: date,
        latitude: latitude,
        longitude: longitude,
        timeZone: timeZone,
        method: BAPrayerMethod.MCW,
        madhab: BAPrayerMadhab.Hanafi
    )
}
```

### `RamadhanSummary`

After obtaining the necessary information, we could wrap one instance of Ramadhan as a struct named [`RamadhanSummary`](https://github.com/ikhsan/FutureOfRamadhan/blob/master/FutureRamadhans/DataCollection.swift#L6).

## Data visualisation

There is nothing special on visualising Ramadhan as a graphic. We only need simple Core Graphic calls to draw coloured bars in the right width and shape.

### Bar

An instance of `RamadhanSummary` is mapped as a `UICollectionViewCell` inside `UICollectionView`. The width of the bar depends on its fasting duration of fasting, whereas the positioning depends on the start time and end time of fasting. Just by using the correct  scale, we could place and size the bar accordingly. We added ticks for every two hours to improve readability.

### Colour

The colour of a bar also depends on its fasting duration, relative to the range of minimum and maximum duration from all Ramadhan in one place. Green (`rgb(46, 204, 113)`) for the shortest duration and orange (`rgb(243, 156, 18)`) for the longest.

We need two parameters to calculate the correct colour; the range of minimum and maximum fasting duration and a duration of a Ramadhan that we want to give a colour.

For example, London has a shortest duration of 14 hours and a longest duration of 20 hours. What colour should we chose for a 18 hours fasting duration of Ramadhan? To give a brief picture of what the question is, try to review the following sketch;

```
duration  14 |------------[18]--------| 20

red      46  |------------[??]--------| 243
green    204 |------------[??]--------| 156
blue     113 |------------{??}--------| 18
```

Below is how we calculate the colour in swift;

```swift
extension UIColor {
    class func rmdn_colorForDuration(duration: Double, range: (min: Double, max: Double)) -> UIColor {
        let minColor: (Double, Double, Double) = (46, 204, 113)
        let maxColor: (Double, Double, Double) = (243, 156, 18)

        let r = minColor.0 + ((maxColor.0 - minColor.0) * ((duration - range.min) / (range.max - range.min)))
        let g = minColor.1 + ((maxColor.1 - minColor.1) * ((duration - range.min) / (range.max - range.min)))
        let b = minColor.2 + ((maxColor.2 - minColor.2) * ((duration - range.min) / (range.max - range.min)))

        return UIColor(
            colorLiteralRed: Float(r / 255.0),
            green: Float(g / 255.0),
            blue: Float(b / 255.0),
            alpha: 1.0
        )
    }
}

// colour calculation
let color = UIColor.rmdn_colorForDuration(18.0, range:(14.0, 20.0)) // rgb(177, 172, 49)
```

### Saving `UICollectionView` as an image

After all the bar is placed and colored correctly, we need to convert all the bars as an image. We could transform a `UIView` as an image using Core Graphic's `UIGraphicsGetImageFromCurrentImageContext()`. But be aware that [we need to set its `frame` first as its `contentSize`](http://stackoverflow.com/questions/14376249/creating-a-uiimage-from-a-uitableview/14376719#14376719), so that the whole `collectionView` is captured.

```swift
extension UICollectionView {
    func rmdn_takeSnapshot() -> UIImage {
        let oldFrame = self.frame

        var frame = self.frame
        frame.size.height = self.contentSize.height // change before capturing the view
        self.frame = frame

        UIGraphicsBeginImageContextWithOptions(self.frame.size, self.opaque, 0)
        self.layer.renderInContext(UIGraphicsGetCurrentContext())
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.frame = oldFrame // set the size back

        return screenshot
    }
}
```
After we got our collection view as an image, we save it in our document directory. The function returns a path to the image if saving is successful.

```swift
extension UIImage {
    func rmdn_saveImageWithName(name: String) -> String {
        guard let documentPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first,
            let image = UIImagePNGRepresentation(self) else {
                return ""
        }

        let filepath = documentPath.stringByAppendingPathComponent("\(name).png")
        let success = image.writeToFile(filepath, atomically: true)
        return success ? filepath : ""
    }
}
```

## Result

Here are the visualisations of fasting duration during Ramadhan of [London](2015-08-06-future-of-ramadhan/london.png), [Tokyo](2015-08-06-future-of-ramadhan/tokyo.png), [Reykjavik](2015-08-06-future-of-ramadhan/reykjavik.png) and [Wellington](2015-08-06-future-of-ramadhan/wellington.png).

![Ramadhan around the world](blog/2015-08-06-future-of-ramadhan/ramadhans.png)

## Summary

I really enjoyed using Swift as a data visualisation tool because there are many frameworks (either Apple's or 3rd party) that we could use. Features like `guard` or `collectionTypes`s functions made reading and writing code more joyful. To check the full source code, go to the [repository on github](https://github.com/ikhsan/FutureOfRamadhan).

In the future, it would be even cooler if we could run this code on playground or as a script. Currently, Core Location's geocoding in simulator behaves differently than in playground or script. Once this is resolved, we should be able to run the same code from terminal.

## Reference

- [Data Visualization and D3.js Course](https://www.udacity.com/course/data-visualization-and-d3js--ud507) by Udacity
- [`BAPrayerTimes`](https://github.com/batoulapps/BAPrayerTimes) by Batoul Apps
- [Guidance for Mac and iOS](http://guidanceapp.com) by Batoul Apps
