---
title: Extending Slather
date: 2015-06-07 23:47 UTC
tags: ruby, slather, objective-c
---

Last month, I went to Facebook for attending Cocoapods' [Test Jam](http://blog.cocoapods.org/Test-Jammin/). The gist of the event is adding tests for established posts together as community. That's when I heard [slather](https://github.com/venmo/slather) for the first time. READMORE

Slather is a ruby gem that generates code coverage reports from your Xcode project and hook it into CI. Installation and usage is simple, you could find your way to their [extensive guide](https://github.com/venmo/slather#installation).

Once your project is hooked to coverage service like coveralls, you will have the ability to review your coverage thoroughly via coveralls' web interface. Coveralls dashboard gives you all the data that you need; total percentage, tabular data of covered files and highlighted source code.

![Coveralls Report Table](/extending-slather/coveralls_2.png)
![Coveralls Line Coverage](/extending-slather/coveralls_1.png)

## Local Usage : HTML Reports

Sometimes, you also want the same information available locally. So you don't need to push any code just to get the information provided by coveralls. The simple output does not give much details. You only get coverage percentage for each file, but not __which lines__ are being covered.

Having this problem, I'm thinking why don't I just extend slather's feature? It would be cool to have the ability to generate reports as static HTML pages. Making as static HTML means that you don't need further setup, other application nor connectivity. Just browser and you are good to go.

First step is to find how to add features. By just browsing the list of merged pull request, you will able to see how people are adding stuff to the project. I used [neonichu](https://github.com/neonichu)'s [GutterJsonOutput PR](https://github.com/venmo/slather/pull/24/files?diff=split) as a guide (file diffing is a great tool for learning how to contribute).

I'm not of a designer so I followed what already worked. Slather already has a delightful logo, so I used its colour scheme. Then I replicate coveralls styling for the tables and the highlighted source code. Syntax highlighting is using [`highlight.js`](https://highlightjs.org/) and sorting-filtering is using [list.js](http://www.listjs.com/).

![Coveralls Report Table](/extending-slather/slather_html_1.png)
![Coveralls Line Coverage](/extending-slather/slather_html_2.png)

To generate the html report, use the `-h` or `--html` flag. By default, it will print the path of the index page. But if you want to open it automatically in your browser, you could use '--show' flag.

```sh
$ slather coverage -h --show path/to/project.xcodeproj
```


## Xcode 7's code coverage support

In WWDC 15, Apple announced code coverage support baked into Xcode. Developers would able to see right inside the code which lines are covered. Would slather and html reports will be futile? I think slather with HTML report has its own advantages. HTMLs are not attached to Xcode, meaning you can do whatever you want with it. Whether just checking locally, or uploading it inside Jenkins. I think there are still values on having slather generating HTML reports.

## Currently in Pending

This feature is still pending as [a pull request](https://github.com/venmo/slather/pull/76). Hopefully, it will get merged soon. 🎉
