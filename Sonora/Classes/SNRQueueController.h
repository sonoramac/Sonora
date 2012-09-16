//
//  SNRQueueController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
