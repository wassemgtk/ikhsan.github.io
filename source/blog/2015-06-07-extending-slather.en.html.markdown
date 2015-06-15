---
title: Extending Slather
date: 2015-06-07 23:47 UTC
tags: ruby, slather, objective-c
---

Last month, I went to Facebook London for attending Cocoapods' [Test Jam](http://blog.cocoapods.org/Test-Jammin/). The gist of the event is adding tests for established posts together as community. That's when I heard **slather** for the first time. READMORE

[Slather](https://github.com/venmo/slather) is a ruby gem that generates code coverage reports from your Xcode project and hook it into CI. Installation and usage is simple, you could find your way to their [extensive guide](https://github.com/venmo/slather#installation).

Once your project is hooked to coverage service like [coveralls](https://coveralls.io), you will have the ability to review your coverage thoroughly via coveralls' web interface. Coveralls dashboard gives you all the data that you need; total percentage, tabular data of covered files and highlighted source code.

![Coveralls Report Table](/extending-slather/coveralls_1.png)

## Local Usage : HTML Reports

Sometimes, you also want the same information available locally. So you don't need to push any code just to get the information provided by coveralls.

With slather, you could have that information using the simple output mode using `-s`. But for me, this does not give much details needed. You only get coverage percentage for each file, but not __which lines__ are being covered. I don't want to push everytime just to check which line is being covered.

Having this problem, I'm thinking why don't I just extend slather's feature? It would be cool to have the ability to generate reports as static HTML pages. Making as static HTML means that you don't need further setup, other application nor connectivity. Just browser and you are good to go.

First step is to find how to add features. By just browsing the list of merged pull request, you will able to see how people are adding stuff to the project. I used [neonichu](https://github.com/neonichu)'s [GutterJsonOutput PR](https://github.com/venmo/slather/pull/24/files?diff=split) as a guide. Use github's file diffing to learn how a good contribution looks like.

I'm not of a designer so I followed what already worked. Slather already has a delightful logo, so I used its colour scheme. Then I replicate Coveralls styling for the tables and the highlighted source code. Syntax highlighting is using [`highlight.js`](https://highlightjs.org/) and sorting-filtering is using [list.js](http://www.listjs.com/).

![Coveralls Report Table](/extending-slather/slather_html_1.png)
![Coveralls Line Coverage](/extending-slather/slather_html_2.png)

To generate the html report, use the `--html` flag. It will print the path of the index page by default, but you can use you could use '--show' flag to open it automatically in your browser.

```sh
$ slather coverage --html --show path/to/project.xcodeproj
```

## It's merged 🎉

Honestly, this is my first real experience on open source contribution. The responses from others are motivating and the end result was rewarding. I really hope that it will be used by many people. [HTML reports generation](https://github.com/venmo/slather/pull/76) is merged to Slather 1.8 update. Woohoo.

### Update WWDC15 : Xcode 7's code coverage support

In WWDC 15, Apple announced code coverage support baked into Xcode. Developers would able to see right inside the code which lines are covered. Does it mean that Slather + html reports will be futile?

I think slather with HTML report has its own advantages. HTMLs are not attached to Xcode, meaning you can do whatever you want with it. Whether to do local review, upload to your site, or integrate it to Jenkins. IMO, there are still values on having slather generating HTML reports.
