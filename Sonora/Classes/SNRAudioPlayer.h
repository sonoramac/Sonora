/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
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