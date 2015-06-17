---
title: Fastlane on Jenkins and its Workarounds
date: 2015-06-09 04:32 UTC
tags: ruby, fastlane, jenkins
---

 __Fastlane__ helps you big time on configuring deployment pipeline. Whether you are using jenkins, travis or even your local machine there are things that you can take advantage from fastlane. READMORE [Fastlane](https://fastlane.tools) comprises different toolsets for different usage. It has [lists of action](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md) that you can use to create your lanes.

Starting is quick. Fastlane has setup assistant that will guide you to make the necessary files.

```sh
$ (sudo) gem install fastlane
$ cd <your project root folder>
$ fastlane init
```

And you are good to go! 👌

## Advantages Compared to Normal Jenkins Job

### Ubiquity
It means that it will run in any machine that has ruby and Fastlane installed. In my workplace, we once had a problem accessing our CI machine for days because we are moving out. We need to make builds quickly, but should have the same same deployment configuration. By having both the fastlane and the project's fastlane actions in each developer's machine, we could make the builds fast and easy.

### Keeping Config in Repository
Since the config files inside Fastlane are just plain texts, we could just include it inside our repository. You don't even need to be proficient in ruby because the syntax is almost like plain english.

### Jenkins integration is (or should be) Easy

Ash wrote a [short and sweet guideline](https://github.com/KrauseFx/fastlane/blob/master/docs/Jenkins.md) on integrating Fastlane. Once jenkins and fastlane is installed in your CI machine, make a job that has two actions: fetching the repository (using git or SVN plugin) and execute script `fastlane build`.

Although it supposed to be effortless, but apparently I met a few problems along the way, which I will be sharing with its solution next.

## Problem with Jenkins

It did not work the first time when I run the fastlane job in Jenkins. Even, there are more gotchas that I came across along the way.

### Jenkins is Using Different Ruby

First time I run the job, jenkins complained that it cannot detect the fastlane command. Whereas it is available and installed when I run using ssh. The [workaround is simple](http://stackoverflow.com/a/10519349/851515), use the `-l` flag to use a login shell.

__Execute shell__

```sh
#!/bin/bash -l
fastlane build
```

### Locked Keychain

I had a Code Signing error that which says the login keychain is locked. To resolve this use `unlock-keychain` with your admin password.

__Execute shell__

```sh
security -v unlock-keychain -p "<your password>" "/Users/<username>/Library/Keychains/login.keychain"
```

### Codesigning Error
This is not necessarily a jenkins problem, but if you come across this problem like [this](http://stackoverflow.com/a/26499526/851515): `/tmp/QYFSJIvu7W/Payload/XX.app/ResourceRules.plist: cannot read resources` then you need to add the ResourceRules.plist to your project.

* Click on your project's target > Build Settings > Code Signing Resource Rules Path
* add `$(SDKROOT)/ResourceRules.plist`

### (Another) Codesigning Error
I stumbled upon this issue when I'm using these two [ipa actions](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md#ipa)' paramaters`embed` and `identity`. It uses `codesign` tools in the background. But I had an error saying that `code failed to satisfy specified code requirement(s)`. After quick search on the internet, I found [this article](http://blog.hoachuck.biz/blog/2013/10/29/codesign-useful-info-in-xcode-5-dot-0-1/) that says that my environment variable that has codesign_allocate's path is incorrect.

The workaround it to force adding it to the job. You can do that either inside the jenkins script or put it inside the Fastfile. My approach is to add it in my Fastfile;

```ruby
platform :ios do
  desc "Making UAT build"
  desc "Send to hockey"
  lane :uat do

    ENV['CODESIGN_ALLOCATE'] = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate"

    increment_build_number

    ipa(
      configuration: "Debug",
      scheme: '<the scheme>',
      destination: "build",
      embed: 'fastlane/<the distribution profile name>.mobileprovision',
      identity: 'iPhone Distribution: <the identity>',
    )

    hockey(
      api_token: HOCKEYAPP_API_TOKEN,
      notes: "UAT build",
    )
  end
end
```
