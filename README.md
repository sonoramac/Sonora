## Sonora
### A minimal, beautifully designed music player for the Mac
#### Developed by [Indragie Karunaratne](http://indragie.com)
#### Designed by [Tyler Murphy](http://twitter.com/tylrmurphy)

![Sonora](http://indragie.com/images/sonora.png)

Sonora (previously sold on the App Store, **now open source**) is a relatively new music player for the mac with a clean, minimal design and some awesome features that greatly enhance your every day music listening experience. Some of the highlights of Sonora include:

- **Visually immersive**. No more long, boring lists of text. View your albums in a grid with gorgeous artwork.
- **Fast**. Almost all of Sonora's UI is built on top of Core Animation, which makes for a super smooth and silky experience.
- **Support for tons of formats**. Literally. Sonora supports every format under the sun, thanks to [SFBAudioEngine](https://github.com/sonoramac/SFBAudioEngine)
- **Instant search**. Type anywhere inside the app to instantly search through your albums, artists, songs, and mixes. It even has a global search window with a customizable hot key to play and enqueue music without interrupting your workflow.
- **Queue**. Sonora utilizes a central queue for all music playback. Easily add, remove, and rearrange songs to customize your listening queue on the fly. Save your queue as a mix with the click of a button.
- **Social**. Built in Last.fm scrobbling and sharing to Twitter, iMessage, and Email (via OS X Mountain Lion).

### Why was this open sourced?

A lot of reasons. Read [this blog post](#) for more information on our decision.

### How to compile

**Prerequisites**

- [mogenerator](https://github.com/rentzsch/mogenerator)
- [CocoaPods](https://github.com/CocoaPods/CocoaPods)

For the next steps, you have two options. There is a fast way to compile Sonora  and the best way. The fast way uses a ZIP of external libraries that I've already set up and configured, but these libraries may not be up to date because I don't have the time to update the ZIP every time something little changes. The best way is to set up the dependencies yourself and ensure that you always have the latest versions of the libraries.


#### Fastest way

- Download the [Libraries.zip](#) file from the Downloads section 
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
- **NOTE:** At the moment, CocoaPods doesn't support turning ARC on and off on a per file basis. In the **OEGridView** pod, `NSColor+OEAdditions.m` needs to be compiled without ARC even though the rest of the source files need it. To turn off ARC for this file, click on the Pods project in the navigator, chose the Pods static library target, go to Build Phases, and under the Compile Sources build phase find the `NSColor+OEAdditions.m` file and remove the `-fobjc-arc` flag.
- Download the submodules:

```
git submodule update --init --recursive
```

- **SFBAudioEngine** requires frameworks that aren't included in the main repository. Download the Frameworks archive [here](https://github.com/downloads/sbooth/SFBAudioEngine/Frameworks.tar.bz2) and place the Frameworks folder inside Sonora/External/SFBAudioEngine/. 


#### After you've followed either method:

- Read instructions in `SNRConstants.m` to fill in extra information that may be necessary
- Compile **(make sure to open Sonora.xcworkspace and not the xcodeproj)!**


### State of the Code

The app is very much functional, but there's certainly a lot of bugs to fix. Large parts of Sonora have been rewritten for Sonora 2, but a lot of old code remains. Some of this was written while I was still in the process of fully learning Cocoa and Objective-C, so I may be doing some unspeakably horrible things :)

I could definitely use everyone's help in fixing and improving things.

### Contributing

One of the reasons we open sourced Sonora is because a music player is difficult for one man to maintain, and the community's help is essential in order to keep Sonora in good shape.

If you want to contribute, please take a look at the issues for this repository and see if there are any bugs in there that you want to fix or features you want to implement. If you need a design to implement a particular feature, please create a new issue with the **design** tag and we'll do our best to supply PSDs.

Once you have made additions, please send us a pull request and we will review and merge your contributions.

### Bugs

If you find a bug, please file an issue with as much information as possible. **DO NOT file issues for feature requests. We get too many of these and we will decide what new features are needed.**

### PSDs

The PSDs for Sonora's design are being cleaned up right now and will be posted in this repository when they are ready.

### License

Sonora is licensed under the BSD license. See LICENSE file for more info.

Please, **please** don't just compile Sonora (or take the code and rename the app) and sell it somewhere. ie. Don't be a terrible person. We decided to use a nonrestrictive license because we hate those other licenses as much as everyone else does.

We've spent many years and thousands of hours working on Sonora, and the last thing we want to see is someone ripping it and selling it for their own profit with minimal effort on their part. **Just don't do it.**