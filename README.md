## Sonora
### A minimal, beautifully designed music player for the Mac
#### Developed by [Indragie Karunaratne](http://indragie.com)
#### Designed by [Tyler Murphy](http://twitter.com/tylrmurphy)

![Sonora](https://raw.github.com/sonoramac/Sonora/master/screenshot.png)

Sonora (previously sold on the App Store, **now open source**) is a relatively new music player for the mac with a clean, minimal design and some awesome features that greatly enhance your every day music listening experience. Some of the highlights of Sonora include:

- **Visually immersive**. No more long, boring lists of text. View your albums in a grid with gorgeous artwork.
- **Fast**. Almost all of Sonora's UI is built on top of Core Animation, which makes for a super smooth and silky experience.
- **Support for tons of formats**. Literally. Sonora supports every format under the sun, thanks to [SFBAudioEngine](https://github.com/sonoramac/SFBAudioEngine)
- **Instant search**. Type anywhere inside the app to instantly search through your albums, artists, songs, and mixes. It even has a global search window with a customizable hot key to play and enqueue music without interrupting your workflow.
- **Queue**. Sonora utilizes a central queue for all music playback. Easily add, remove, and rearrange songs to customize your listening queue on the fly. Save your queue as a mix with the click of a button.
- **Social**. Built in Last.fm scrobbling and sharing to Twitter, iMessage, and Email (via OS X Mountain Lion).

### Why was this open sourced?

A lot of reasons. Read [this blog post](http://blog.indragie.com/post/1-2-open-source) for more information on our decision.

### How to compile

**Prerequisites**

- [mogenerator](https://github.com/rentzsch/mogenerator)
- [CocoaPods](https://github.com/CocoaPods/CocoaPods)

For the next steps, you have two options. There is a fast way to compile Sonora  and the best way. The fast way uses a ZIP of external libraries that I've already set up and configured, but these libraries may not be up to date because I don't have the time to update the ZIP every time something little changes. The best way is to set up the dependencies yourself and ensure that you always have the latest versions of the libraries.


#### Fastest way

- Download the [Libraries.zip](https://github.com/downloads/sonoramac/Sonora/Libraries.zip) file from the Downloads section 
- Unzip it into the Sonora folder, replacing existing directories if necessary

#### Best way

- Add the Sonora podspecs repository to CocoaPods:

```
pod repo add Sonora-Podspecs git://github.com/sonoramac/Podspecs.git master
```
- Download and set up all the pods:

```
cd <project directory>
pod install
```
- Download the submodules:

```
git submodule update --init --recursive
```

- **SFBAudioEngine** requires frameworks that aren't included in the main repository. Download the Frameworks archive [here](http://files.sbooth.org/SFBAudioEngine-dependencies.tar.bz2) and place the Frameworks folder inside Sonora/External/SFBAudioEngine/. 


#### After you've followed either method:

- Read instructions in `SNRConstants.m` to fill in extra information that may be necessary
- Compile **(make sure to open Sonora.xcworkspace and not the xcodeproj)!**


### State of the Code

The app is very much functional, but there's certainly a lot of bugs to fix. Large parts of Sonora have been rewritten for Sonora 2, but a lot of old code remains. Some of this was written while I was still in the process of fully learning Cocoa and Objective-C, so I may be doing some unspeakably horrible things :)

I could definitely use everyone's help in fixing and improving things.


### Looking for Sonora 1.0?

The source code in this repository is for Sonora 2.0. If you're looking for the version of Sonora that used to be sold on the Mac App Store (1.0.x) you can [**download it here**](https://s3-us-west-2.amazonaws.com/sonora-mac/Sonora_1.0.2.zip).

You should delete the preferences file for Sonora 2 from **~/Library/Preferences/com.iktm.Sonora.plist** before running this version because they both use the same bundle identifier.

### Contributing

One of the reasons we open sourced Sonora is because a music player is difficult for one man to maintain, and the community's help is essential in order to keep Sonora in good shape.

If you want to contribute, please take a look at the issues for this repository and see if there are any bugs in there that you want to fix or features you want to implement. If you need a design to implement a particular feature, please create a new issue with the **design** tag and we'll do our best to supply PSDs.

Once you have made additions, please send us a pull request and we will review and merge your contributions. If you're actively making large contributions to Sonora, we would love to add you to the team and give you push access to the repository so that you won't need to bother with pull requests.

### Bugs

If you find a bug, please file an issue with as much information as possible. **DO NOT file issues for feature requests. We get too many of these and we will decide what new features are needed.**

### PSDs

The PSDs for Sonora's design are being cleaned up right now and will be posted in this repository when they are ready.

### License

All of Sonora's assets (everything inside the Resources folder) are Copyright (C) 2014 Tyler Murphy and are **NOT licensed for any commercial or non-commercial use**.

Sonora's **code** is licensed under the BSD 3-Clause license. See LICENSE file for more info.

In other words:

1. You can use the code in accordance with the BSD 3-Clause license.
2. You can not use the design assets for any purpose.
3. You may not redistribute the application in any form, commercial or non-commercial.
