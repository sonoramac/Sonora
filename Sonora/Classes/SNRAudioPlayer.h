//
//  SNRAudioPlayer.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-18.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNRAudioPlayerDelegate;
@interface SNRAudioPlayer : NSObject
@property (nonatomic, assign) id<SNRAudioPlayerDelegate> delegate;
@property (nonatomic, readonly) BOOL isPlaying;
@property (nonatomic, readonly) BOOL isPaused;
@property (nonatomic, readonly) BOOL isStopped;
@property (nonatomic, readonly) NSURL *playingURL;
@property (nonatomic, readonly) NSTimeInterval currentTime;
@property (nonatomic, readonly) NSTimeInterval totalTime;
@property (nonatomic, readonly) NSUInteger currentFrame;
@property (nonatomic, readonly) NSUInteger totalFrames;
@property (nonatomic, readonly) BOOL supportsSeeking;
@property (nonatomic, assign) float volume;
@property (nonatomic, assign) float preGain;
- (IBAction)play:(id)sender;
- (IBAction)playPause:(id)sender;
- (IBAction)pause:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)seekForward:(id)sender;
- (IBAction)seekBackward:(id)sender;
- (BOOL)seekToTime:(NSTimeInterval)time;
- (BOOL)enqueueURL:(NSURL*)url;
- (BOOL)clearEnqueuedTracks;
- (BOOL)skipToNextEnqueuedTrack;

- (void)seekForwardWithSeconds:(NSTimeInterval)seconds;
- (void)seekBackwardWithSeconds:(NSTimeInterval)seconds;
- (void)setEQValue:(float)value forEQBand:(int)band;
@end

@protocol SNRAudioPlayerDelegate <NSObject>
@optional
- (void)audioPlayerStartedPlaying:(SNRAudioPlayer*)player;
- (void)audioPlayerFinishedPlaying:(SNRAudioPlayer*)player;
- (void)audioPlayerStartedDecoding:(SNRAudioPlayer*)player;
- (void)audioPlayerFinishedDecoding:(SNRAudioPlayer*)player;
- (void)audioPlayerWantsUIUpdate:(SNRAudioPlayer*)player;
@end