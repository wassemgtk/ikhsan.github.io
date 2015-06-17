---
title: Fastlane on jenkins
date: 2015-06-17 04:32 UTC
tags: ruby, fastlane, ci, jenkins
---

what is fastlane (1-2 words)

## Advantages compared to normal jenkins job
* ubiquity - able to build w/ local machine (as long it has the ruby)
* scripts and configurations are kept inside repository
* jenkins integration (should be) is easy (more on this later)

Hopefully, will support android as well

## Problem with Jenkins

Guide on using fastlane for jenkins

### jenkins using different ruby version
using ruby from jenkins (#!/bin/bash -l) : http://stackoverflow.com/questions/10209242/rvm-and-jenkins-setup

### unlocking keychain


### error on uploading to hockey
not necessarily jenkins problem
Error creating ipa - hockey : http://stackoverflow.com/a/26499526/851515

### codesigning error
CODESIGN_ALLOCATE ; /Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/codesign_allocate
