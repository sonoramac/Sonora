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
#import "SNRAudioPlayer.h"
#import "SNRQueueView.h"
#import "SNRArtworkCache.h"
#import "SNRRestorationManager.h"
#import "SNRQueueItem.h"

enum {
    SNRQueueControllerRepeatModeNone = 0,
	SNRQueueControllerRepeatModeAll = 1,
    SNRQueueControllerRepeatModeOne = 2
};
typedef NSInteger SNRQueueControllerRepeatMode;

enum {
    SNRQueueControllerPlayerStateStopped = 0,
    SNRQueueControllerPlayerStatePaused = 1,
    SNRQueueControllerPlayerStatePlaying = 2
};
typedef NSInteger SNRQueueControllerPlayerState;

@interface SNRQueueController : NSObject <SNRAudioPlayerDelegate, NSMenuDelegate, SNRQueueViewDataSource, SNRQueueViewDelegate, SNRRestorableState>

#pragma mark - Audio Player
@property (nonatomic, retain, readonly) SNRAudioPlayer *audioPlayer;
@property (nonatomic, readonly) SNRQueueControllerPlayerState playerState;
@property (nonatomic, assign) SNRQueueControllerRepeatMode repeatMode;
@property (nonatomic, strong) SNRArtworkCache *artworkCache;

#pragma mark - Restoration
@property (nonatomic, strong) NSString *identifier;

@property (nonatomic, strong) id representedObject;
@property (nonatomic, assign) BOOL loadArtworkSynchronously;

#pragma mark - Queue Access
@property (nonatomic, readonly) NSArray *queue;
@property (nonatomic, readonly) NSArray *queueItems;
@property (nonatomic, strong) SNRQueueItem *currentQueueItem;

#pragma mark - UI
@property (nonatomic, weak) IBOutlet SNRQueueView *queueView;

- (SNRSong *)currentSong;

#pragma mark - Playback Controls

- (void)play;
- (void)playFromSong:(SNRSong*)song;
- (void)playPause;
- (void)pause;
- (void)stop;
- (void)next;
- (void)previous;
- (void)shuffle;
- (void)seekForward;
- (void)seekBackward;
- (void)seekForward:(NSTimeInterval)seconds;
- (void)seekBackward:(NSTimeInterval)seconds;
- (void)seekToTime:(NSTimeInterval)time;

- (NSTimeInterval)currentPlaybackTime;
- (NSTimeInterval)totalPlaybackTime;

#pragma mark - Queue Controls

- (void)clearQueueImmediately:(BOOL)immediately;

- (void)enqueueSongs:(NSArray*)songs;
- (void)enqueueObjects:(NSArray*)objects;
- (void)enqueueObjectsAndShuffle:(NSArray*)objects;
- (void)playSongs:(NSArray*)songs;
- (void)playObjects:(NSArray*)objects;
- (void)shuffleSongs:(NSArray*)songs;
- (void)shuffleObjects:(NSArray*)objects;
@end
