---
title: Fastlane on Jenkins and its Workarounds
date: 2015-06-09 04:32 UTC
tags: ruby, fastlane, jenkins
---

 __Fastlane__ helps you configure your deployment pipeline. There are advantages by using fastlane whichever CI solution you have, whether it's Travis in the cloud, Jenkins in your local CI machine or even your own dev machine. READMORE [Fastlane](https://fastlane.tools) comprises different toolsets for different purposes. First thing you might want to look at is its [list of actions](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md).

Starting is quick and easy. Fastlane even has its own setup assistant to help you out.

```sh
$ (sudo) gem install fastlane
$ cd <your project root folder>
$ fastlane init
```

And you are good to go! 👌

## Advantages Compared to Normal Jenkins Job

### Ubiquity
Fastlane runs in any machine that has ruby and Fastlane gem installed. We had a problem accessing our Jenkins server for days because we are moving out. In the other hand, clients still need their builds ready.  By having Fastlane and its config file in each developer's machine, everyone could still make the same build without access to our Jenkins server.

### Config inside Repository
The config files (known as `Fastfile`) are just plain texts, so we could just easily include it inside our repository. You don't even need to be proficient in ruby because the syntax is pretty close to plain english.

### Jenkins integration is (or should be) Easy

[Ash Furrow](https://twitter.com/ashfurrow) wrote a [short and sweet guideline](https://github.com/KrauseFx/fastlane/blob/master/docs/Jenkins.md) on integrating Fastlane to Jenkins. Once Jenkins and Fastlane is installed in your CI machine, you need to create a job that has two things: fetching the repository (using git or SVN plugin) and execute the Fastlane's script (`fastlane <your lane>`).

## Problem with Jenkins

Integrating with Jenkins supposed to be effortless, but in my experience I met few problems along the way.

### Jenkins is Using Different Ruby

First time I run the job, Jenkins complained that it cannot detect the `fastlane` command. I double checked via ssh and everything are installed. My [workaround was simple](http://stackoverflow.com/a/10519349/851515), I specify the `-l` flag to use the login shell.

__'Execute shell' in Jenkins__

```sh
#!/bin/bash -l

# I have a 'build' lane configured in `Fastfile`
fastlane build
```

### Locked Keychain

I had a Code Signing error that which says the login keychain is locked. To resolve this use `unlock-keychain` with your admin password.

__Execute shell__

```sh
security -v unlock-keychain -p "<your password>" "/Users/<username>/Library/Keychains/login.keychain"
fastlane build
```

### Codesigning Error
This is not necessarily a Jenkins-specific problem, but if you come across this problem like [this](http://stackoverflow.com/a/26499526/851515): "`/tmp/QYFSJIvu7W/Payload/XX.app/ResourceRules.plist: cannot read resources`", then you need to add the `"ResourceRules.plist"` to your project.

* Click on your project's target > Build Settings > Code Signing Resource Rules Path
* add `$(SDKROOT)/ResourceRules.plist`

### (Another) Codesigning Error
I stumbled upon this issue when I'm using these two [ipa actions](https://github.com/KrauseFx/fastlane/blob/master/docs/Actions.md#ipa) paramaters: `'embed'` and `'identity'`. It uses `codesign` tools in the background. But I had an error saying that `"code failed to satisfy specified code requirement(s)"`. After quick search on the internet, I found [an article](http://blog.hoachuck.biz/blog/2013/10/29/codesign-useful-info-in-xcode-5-dot-0-1/) that explains that I'm having an incorrect codesign_allocate's path.

The workaround it to force adding it to the job. You can do that either inside the jenkins script or put it inside the Fastfile. My approach is to add it in my Fastfile;

```ruby
platform :ios do
  desc "Making a build" # name of the lane
  lane :build do

    # force change environment variables for codesign_allocate tool
    ENV['CODESIGN_ALLOCATE'] = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate"

    ipa(
      configuration: "Debug",
      scheme: 'MyApp', # your scheme
      destination: "build", # your destination directory
      embed: 'fastlane/my_distribution_cert.mobileprovision', # your distribution profile name
      identity: 'iPhone Distribution: Ikhsan Assaat', # your identity
    )
  end
end
```
