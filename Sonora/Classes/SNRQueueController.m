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

#import "SNRQueueController.h"
#import "SNRQueueViewCell.h"
#import "SNRQueueEmptyView.h"
#import "SNRBlockMenuItem.h"
#import "SNRAlbum.h"
#import "SNRSong.h"

#import "NSArray-SNRAdditions.h"
#import "NSUserDefaults-SNRAdditions.h"
#import "NSView-SNRAdditions.h"

static NSString* const kDistNotificationSenderName = @"Sonora";
static NSString* const kDistNotificationPlayerStateChanged = @"com.iktm.Sonora.stateChanged";
static NSString* const kDistNotificationCurrentTrackChanged = @"com.iktm.Sonora.trackChanged";

static NSString* const kRestorationKeyQueueItems = @"queueItems";
static NSString* const kRestorationKeyPlaybackTime = @"playbackTime";
static NSString* const kRestorationKeyCurrentPlaybackItem = @"currentPlaybackItem";

static NSString* const kImageGeneric = @"default-queue-artwork";

#define kPreloadingTimeThreshold 0.5

@interface SNRQueueController ()
#pragma mark - Private
- (void)setupNotificationsAndBindings;
- (void)clearEnqueuedQueueItems;
- (NSString *)prefixedRestorationKeyForKey:(NSString*)key;

#pragma mark - Queue
- (SNRQueueItem *)nextQueueItem;
- (SNRQueueItem *)previousQueueItem;
- (SNRQueueItem *)attemptToEnqueueQueueItem:(SNRQueueItem *)item;;
- (BOOL)enqueueQueueItem:(SNRQueueItem *)item;
- (BOOL)preloadNextQueueItem;
- (void)updateCachedPlayingIndex;

#pragma mark - User Interface
- (void)updateTrackProgress;

#pragma mark - Notifications
- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification;
@property (nonatomic, assign) SNRQueueControllerPlayerState playerState;
@property (nonatomic, assign, readonly) BOOL playing;

@property (nonatomic, strong) SNRQueueItem *preloadedQueueItem;
@property (nonatomic, assign) NSTimeInterval restoredPlaybackTime;
@end

@implementation SNRQueueController {
    NSArrayController *_arrayController;
    SNRArtworkCache *_artworkCache;
    
    SNRAudioPlayer *_player;
    NSTimer *_previousClickTimer;
    NSUInteger _cachedPlayingIndex;
    BOOL _beginPlayingWhenReady;
}
@synthesize queueView = _queueView;
@synthesize playerState = _playerState;
@synthesize currentQueueItem = _currentQueueItem;
@synthesize preloadedQueueItem = _preloadedQueueItem;
@synthesize restoredPlaybackTime = _restoredPlaybackTime;
@synthesize representedObject = _representedObject;
@synthesize loadArtworkSynchronously = _loadArtworkSynchronously;

#pragma mark - Initialization

- (id)init
{
    if ((self = [super init])) {
        _cachedPlayingIndex = NSNotFound;
        _player = [SNRAudioPlayer new];
        _arrayController = [[NSArrayController alloc] init];
        _artworkCache = [SNRArtworkCache new];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [_player setDelegate:self];
        [_player setVolume:[userDefaults volume]];
        [_arrayController setContent:[NSMutableArray array]];
        [self setRepeatMode:[userDefaults repeatMode]];
        [self setupNotificationsAndBindings];
    }
    return self;
}

- (void)setupNotificationsAndBindings
{
    NSUserDefaultsController *ud = [NSUserDefaultsController sharedUserDefaultsController];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [_player bind:@"volume" toObject:ud withKeyPath:@"values.volume" options:nil];
    [ud addObserver:self forKeyPath:@"values.repeatMode" options:0 context:NULL];
    [_arrayController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
    [nc addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:SONORA_MANAGED_OBJECT_CONTEXT];
}

#pragma mark - Key Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    BOOL preloadNextTrack = NO;
    if (object == _arrayController && [keyPath isEqualToString:@"arrangedObjects"]) {
        // When this notification is observed, it means that songs have been added or removed from the queue
        preloadNextTrack = YES;
        [self.queueView reloadData];
        [self updateCachedPlayingIndex];
    } else if ([keyPath isEqualToString:@"values.repeatMode"]) {
        self.repeatMode = [[NSUserDefaults standardUserDefaults] repeatMode];
        preloadNextTrack = YES;
    }
    if (preloadNextTrack) {
        NSTimeInterval totalTime = [self totalPlaybackTime];
        NSTimeInterval currentTime = [self currentPlaybackTime];
        if (totalTime && currentTime >= (totalTime * kPreloadingTimeThreshold)) {
            [self clearEnqueuedQueueItems];
            [self preloadNextQueueItem];
        }
    }
}

- (void)dealloc
{
    [_player unbind:@"volume"];
    NSUserDefaultsController *ud = [NSUserDefaultsController sharedUserDefaultsController];
    [ud removeObserver:self forKeyPath:@"values.repeatMode"];
    [_arrayController removeObserver:self forKeyPath:@"arrangedObjects"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSSet *deleted = [userInfo valueForKey:NSDeletedObjectsKey];
    NSMutableArray *remove = [NSMutableArray array];
    BOOL removedCurrentPlaybackItem = NO;
    NSArray *queueItems = [self queueItems];
    // Check the deleted objects to see if anything in the queue was deleted
    for (NSManagedObject *object in deleted) {
        if (![object isKindOfClass:[SNRSong class]]) { continue; }
        for (NSInteger i = 0; i < [queueItems count]; i++) {
            SNRQueueItem *item = [queueItems objectAtIndex:i];
            if (![item.song isEqual:object]) { continue; }
            [remove addObject:item];
            if (item == self.currentQueueItem)
                removedCurrentPlaybackItem = YES;
            break;
        }
    }
    // If the current queue item was removed, skip to the next one
    if (removedCurrentPlaybackItem)
        [self next];
    if ([remove count]) {
        [_arrayController removeObjects:remove];
        queueItems = [self queueItems]; // refresh
    }
}

#pragma mark - Public Accessors

- (NSArray *)queueItems { return [_arrayController arrangedObjects]; }
- (NSArray *)queue { return [[self queueItems] valueForKey:@"song"]; }
- (SNRSong *)currentSong { return [self.currentQueueItem song]; }
- (NSTimeInterval)currentPlaybackTime { return [_player currentTime]; }
- (NSTimeInterval)totalPlaybackTime { return [_player totalTime]; }
- (SNRAudioPlayer*) audioPlayer { return _player; }

- (void)setQueueView:(SNRQueueView *)queueView
{
    if (_queueView != queueView) {
        if (queueView) {
            _queueView = queueView;
            [_queueView setDelegate:self];
            [_queueView setDataSource:self];
            [_queueView reloadData];
            [_queueView setPlayingIndex:_cachedPlayingIndex];
        } else {
            [_queueView setDataSource:nil];
            [_queueView setDelegate:nil];
            [_queueView reloadData];
            [_queueView setPlayingIndex:NSNotFound];
            _queueView = nil;
        }
    }
}

#pragma mark - Queue

// ---------------------
// This method attempts to enqueue the item passed by the argument
// but return a different one if the desired item is invalid
// ---------------------

- (SNRQueueItem *)attemptToEnqueueQueueItem:(SNRQueueItem *)item
{
    NSURL *itemURL = [[item song] url];
    while (itemURL && ![_player enqueueURL:itemURL]) {
        // Remove the item from the queue if it fails to enqueue
        [_arrayController removeObject:item];
        // TODO: code to inform the user why the item was removed
        item = [self nextQueueItem];
        itemURL = [[item song] url];
    }
    return item;
}

// ---------------------
// Immediately begin to play the specified item
// ---------------------

- (BOOL)enqueueQueueItem:(SNRQueueItem *)item
{
    [self stop];
    [self clearEnqueuedQueueItems];
    _beginPlayingWhenReady = YES;
    self.currentQueueItem = [self attemptToEnqueueQueueItem:item];
    return (self.currentQueueItem != nil);
}

// ---------------------
// Preloads the specific item so that it will play immediately after the current item
// ---------------------

- (BOOL)preloadNextQueueItem
{
    // If the repeat mode is one, then return the same item we're already playing
    if (self.repeatMode == SNRQueueControllerRepeatModeOne) {
        self.preloadedQueueItem = [self attemptToEnqueueQueueItem:self.currentQueueItem];
    } else {
        SNRQueueItem *nextItem = [self nextQueueItem];
        // Do a check to make sure that the item isn't already preloaded
        if (nextItem != self.preloadedQueueItem) {
            self.preloadedQueueItem = [self attemptToEnqueueQueueItem:nextItem];
        }
    }
    return (self.preloadedQueueItem != nil);
}

// ---------------------
// Return the next queue item in the queue
// ---------------------

- (SNRQueueItem *)nextQueueItem
{
    if (!self.currentQueueItem) { return nil; }
    NSUInteger currentQueueIndex = _cachedPlayingIndex;
    NSUInteger nextQueueIndex = currentQueueIndex+1;
    NSArray *queueItems = [self queueItems];
    // Check to see if there is a another item in the queue and return that
    if (currentQueueIndex != NSNotFound && nextQueueIndex < [queueItems count]) {
        return [queueItems objectAtIndex:nextQueueIndex];
    // Otherwise if the user has _REPEAT ALL_ turned on, return the first item again
    } else if (self.repeatMode == SNRQueueControllerRepeatModeAll && [queueItems count]) {
        return [queueItems objectAtIndex:0];
    }
    return nil;
}

// ---------------------
// Return the next previous item in the queue
// ---------------------

- (SNRQueueItem *)previousQueueItem
{
    if (!self.currentQueueItem) { return nil; }
    NSArray *queueItems = [self queueItems];
    // Return the previous item if it exists
    NSUInteger currentQueueIndex = _cachedPlayingIndex;
    NSInteger previousQueueIndex = _cachedPlayingIndex - 1;
    if (currentQueueIndex != NSNotFound && previousQueueIndex >= 0) {
        return [queueItems objectAtIndex:previousQueueIndex];
    }
    // Otherwise return the same item that's already playing
    return self.currentQueueItem;
}

// --------------------
// Since the playback item's index is fragile, we try to rely on it
// as little as possible. For the few cases that we require to have an
// index available (e.g. to find the next or previous item) we store
// a cached playing index that's only updated when queue items are
// moved, removed, or inserted
// --------------------

- (void)updateCachedPlayingIndex
{
    if (self.currentQueueItem)
        _cachedPlayingIndex = [[self queueItems] indexOfObject:self.currentQueueItem];
    else
        _cachedPlayingIndex = NSNotFound;
    // Once the playing index has been updated, the UI needs to be reloaded to match
    // Iterate only the visible cells since any invisible cells will be reloaded abefore being displayed
    for (SNRQueueViewCell *cell in [self.queueView visibleCells]) {
        NSUInteger cellIndex = [self.queueView indexForCell:cell];
        // Dim the cell if the index is below the current playing index
        cell.dimmed = _cachedPlayingIndex != NSNotFound && cellIndex < _cachedPlayingIndex;
        BOOL nowPlaying = cellIndex == _cachedPlayingIndex;
        [cell setNowPlaying:nowPlaying animated:YES];
        if (nowPlaying) {
            cell.playbackState = self.playerState == SNRQueueControllerPlayerStatePlaying;
        }
    }
    BOOL newPlayingIndex = [self.queueView playingIndex] != _cachedPlayingIndex;
    [self.queueView setPlayingIndex:_cachedPlayingIndex];
    if (newPlayingIndex) {
        [self.queueView scrollToPlayingIndexAnimated:YES];
    }
}

#pragma mark - Private Accessors

- (BOOL)playing { return self.playerState == SNRQueueControllerPlayerStatePlaying; }

- (void)setPlayerState:(SNRQueueControllerPlayerState)playerState
{
    if (_playerState != playerState) {
        // Post manual KVO for the playing key to update the cell state
        _playerState = playerState;
        BOOL playing = _playerState == SNRQueueControllerPlayerStatePlaying;
        for (SNRQueueViewCell *cell in [self.queueView visibleCells]) {
            if (cell.nowPlaying)
                cell.playbackState = playing;
        }
        // Post distributed notification to let other apps know
        [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kDistNotificationPlayerStateChanged object:kDistNotificationSenderName userInfo:nil deliverImmediately:YES];
    }
}

- (void)setCurrentQueueItem:(SNRQueueItem *)currentQueueItem
{
    BOOL newQueueItem = _currentQueueItem != currentQueueItem;
    _currentQueueItem = currentQueueItem;
    [_currentQueueItem setPlayed:NO];
    // There are checks built into these methods in SNRQueueItem
    // to make sure that they only run if the preferences for them
    // are enabled
    [_currentQueueItem lastFMUpdateNowPlaying];
    [_currentQueueItem postGrowlNotification];
    [self updateCachedPlayingIndex];
    if (!_currentQueueItem) {
        [self stop];
    } else if (newQueueItem) {
        // Only post a notification when the queue item has actually changed
        NSDistributedNotificationCenter *nc = [NSDistributedNotificationCenter defaultCenter] ;
        [nc postNotificationName:kDistNotificationCurrentTrackChanged object:kDistNotificationSenderName userInfo:nil deliverImmediately:YES];
    }
}

#pragma mark - Queue Controls

// --------------------
// Unless immediately = YES, this method will only clear
// all the queue items except the currently playing one.
// If there is only one item in the queue, it will proceed
// to clear that item and stop playback
// --------------------

- (void)clearQueueImmediately:(BOOL)immediately
{
    NSArray *queueItems = [self queueItems];
    if (immediately || [queueItems count] <= 1 || !self.currentQueueItem) {
        // Stop player, clear everything
        [self stop];
        [self clearEnqueuedQueueItems];
        self.currentQueueItem = nil;
        [_arrayController setContent:[NSMutableArray array]];
        [_artworkCache removeAllCachedArtwork];
    } else if (self.currentQueueItem) {
        // Remove everything but the currently playing item
        [_arrayController setContent:[NSMutableArray arrayWithObject:self.currentQueueItem]];
    }
}

// --------------------
// Clear all the preloaded tracks in the player
// --------------------

- (void)clearEnqueuedQueueItems
{
    [_player clearEnqueuedTracks];
    self.preloadedQueueItem = nil;
}

// --------------------
// Begin playback from the specified song instead of the
// start of the queue
// --------------------

- (void)playFromSong:(SNRSong *)song
{
    for (SNRQueueItem *item in [self queueItems]) {
        if ([item.song isEqual:song]) {
            [self enqueueQueueItem:item];
            break;
        }
    }
}

// --------------------
// Begin playing if there's a playback item set
// Otherwise play the first item in the queue
// --------------------

- (void)play
{
    NSArray *queueItems = [self queueItems];
    if (self.currentQueueItem && !_beginPlayingWhenReady) {
        [_player play:nil];
        if ([_player isPlaying]) {
            [self setPlayerState:SNRQueueControllerPlayerStatePlaying];
        }
    } else if ([queueItems count]) {
        [self enqueueQueueItem:[queueItems objectAtIndex:0]];
    }
}

// --------------------
// Pause playback
// --------------------

- (void)pause
{
    [_player pause:nil];
    if (![_player isPlaying]) {
        [self setPlayerState:SNRQueueControllerPlayerStatePaused];
    }
}

// --------------------
// Pause/play toggle
// --------------------

- (void)playPause;
{
    [_player isPlaying] ? [self pause] : [self play];
}

// --------------------
// Skip to the next item in the queue
// --------------------

- (void)next
{
    // If the repeat mode is set to Repeat One we want to
    // bypass the default preload and enqueue the *actual* next item
    if (self.repeatMode == SNRQueueControllerRepeatModeOne || !self.preloadedQueueItem) {
        SNRQueueItem *nextItem = [self nextQueueItem];
        if (nextItem) {
            [self enqueueQueueItem:nextItem];
        } else {
            [self clearQueueImmediately:YES];
        }
    // Otherwise just skip to the next one as usual
    } else {
        [_player skipToNextEnqueuedTrack];
        self.currentQueueItem = self.preloadedQueueItem;
    }
}

// --------------------
// Skip to the previous item in the queue
// --------------------

- (void)previous
{
    // If the timer is still running then seek to the beginning of the song
    if (![_previousClickTimer isValid]) {
        [self seekToTime:0];
    } else {
        // Be efficient here and check if the previous item is actually
        // different from the current item and if it's the same,
        // seek to the beginning instead of enqueuing it all over again
        SNRQueueItem *item = [self previousQueueItem];
        if (item != self.currentQueueItem) {
            [self enqueueQueueItem:item];
        } else {
            [self seekToTime:0];
        }
    }
    // Schedule a timer that dictates whether a click
    // is interpreted as a "seek to beginning" event
    // or a previous event
    _previousClickTimer = [NSTimer scheduledTimerWithTimeInterval:0.7 target:nil selector:nil userInfo:nil repeats:NO];
}

// --------------------
// Shuffles the songs in the queue
// --------------------

- (void)shuffle
{
    // Shuffle but leave the currently playing item at the beginning
    NSMutableArray *items = [[self queueItems] mutableCopy];
    if (self.currentQueueItem)
        [items removeObject:self.currentQueueItem];
    [items randomize];
    if (self.currentQueueItem)
        [items insertObject:self.currentQueueItem atIndex:0];
    [_arrayController setContent:items];
}

// --------------------
// Stops audio playback
// --------------------

- (void)stop
{
    [_player stop:nil];
}

// --------------------
// Seeks forward at the default rate
// --------------------

- (void)seekForward
{
    [_player seekForward:nil];
    [self updateTrackProgress];
}

// --------------------
// Seeks backward at the default rate
// --------------------

- (void)seekBackward
{
    [_player seekBackward:nil];
    [self updateTrackProgress];
}

// --------------------
// Seeks forward at the specified rate
// --------------------

- (void)seekForward:(NSTimeInterval)seconds
{
    [_player seekForwardWithSeconds:seconds];
    [self updateTrackProgress];
}

// --------------------
// Seeks backward at the specified rate
// --------------------

- (void)seekBackward:(NSTimeInterval)seconds
{
    [_player seekBackwardWithSeconds:seconds];
    [self updateTrackProgress];
}

// --------------------
// Seeks to the specified time in the track
// --------------------

- (void)seekToTime:(NSTimeInterval)time
{
    [_player seekToTime:time];
    [self updateTrackProgress];
}

#pragma mark - SNRAudioPlayerDelegate

// --------------------
// This method is called when the audio player
// has actually started decoding the audio data
// (not necessarily right after the song is enqueued)
// --------------------

- (void)audioPlayerStartedDecoding:(SNRAudioPlayer*)player
{
    if (_beginPlayingWhenReady) {
        _beginPlayingWhenReady = NO;
        [self play];
    }
    // If playback time has been restored, seek
    if (self.restoredPlaybackTime) {
        [self seekToTime:self.restoredPlaybackTime];
        self.restoredPlaybackTime = 0.0;
    }
}

// --------------------
// Update the current queue item property
// --------------------

- (void)audioPlayerFinishedPlaying:(SNRAudioPlayer*)player
{
    self.currentQueueItem = self.preloadedQueueItem;
    if (!self.currentQueueItem) {
        [self clearQueueImmediately:YES];
    }
}

// --------------------
// Called repeatedly by a timer to update UI
// --------------------

- (void)audioPlayerWantsUIUpdate:(SNRAudioPlayer*)player
{
    if (self.playerState != SNRQueueControllerPlayerStatePlaying) { return; }
    [self updateTrackProgress];
}

#pragma mark - User Interface

// --------------------
// Update the scrubbing bar
// --------------------

- (void)updateTrackProgress
{
    NSTimeInterval totalTime = _player.totalTime;
    NSTimeInterval currentTime = _player.currentTime;
    // Preload the next song if the song is more than half played
    if (totalTime && currentTime >= (totalTime * kPreloadingTimeThreshold) && ![self.currentQueueItem played]) {
        [self.currentQueueItem setPlayed:YES];
        [self preloadNextQueueItem];
    }
    for (SNRQueueViewCell *cell in [self.queueView visibleCells]) {
        if (cell.nowPlaying) {
            cell.progressMaxValue = totalTime;
            cell.progressDoubleValue = currentTime;
            cell.remainingTime = totalTime - currentTime;
        }
    }
}

#pragma mark - State Restoration

// --------------------
// Returns a prefixed restoration key to avoid
// conflict when there are multiple queue controllers
// --------------------

- (NSString *)prefixedRestorationKeyForKey:(NSString*)key
{
    return [NSString stringWithFormat:@"%@_%@", self.identifier, key];
}

// --------------------
// Encode queue items, playback time, and current item
// --------------------

- (void)encodeRestorableStateWithArchiver:(NSKeyedArchiver *)archiver
{
    NSString *queueItemsKey = [self prefixedRestorationKeyForKey:kRestorationKeyQueueItems];
    NSString *playbackTimeKey = [self prefixedRestorationKeyForKey:kRestorationKeyPlaybackTime];
    NSString *currentItemKey = [self prefixedRestorationKeyForKey:kRestorationKeyCurrentPlaybackItem];
    [archiver encodeObject:[self queueItems] forKey:queueItemsKey];
    [archiver encodeDouble:_player.currentTime forKey:playbackTimeKey];
    [archiver encodeObject:self.currentQueueItem forKey:currentItemKey];
}

// --------------------
// Decode queue items, playback time, and current item
// --------------------

- (void)decodeRestorableStateWithArchiver:(NSKeyedUnarchiver *)unarchiver
{
    NSString *queueItemsKey = [self prefixedRestorationKeyForKey:kRestorationKeyQueueItems];
    NSString *playbackTimeKey = [self prefixedRestorationKeyForKey:kRestorationKeyPlaybackTime];
    NSString *currentItemKey = [self prefixedRestorationKeyForKey:kRestorationKeyCurrentPlaybackItem];
    NSArray *queueItems = [unarchiver decodeObjectForKey:queueItemsKey];
    NSTimeInterval playbackTime = [unarchiver decodeDoubleForKey:playbackTimeKey];
    SNRQueueItem *currentItem = [unarchiver decodeObjectForKey:currentItemKey];
    if ([queueItems count]) {
        [_arrayController addObjects:queueItems];
        if (currentItem) {
            self.restoredPlaybackTime = playbackTime;
            self.currentQueueItem = [self attemptToEnqueueQueueItem:currentItem];
        }
    }
}

#pragma mark - SNRQueueViewDelegate

- (NSUInteger)numberOfItemsInQueueView:(SNRQueueView *)queueView
{
    return [[self queueItems] count];
}

- (OEGridViewCell *)queueView:(SNRQueueView *)queueView cellForItemAtIndex:(NSUInteger)index
{
	SNRQueueViewCell *item = (SNRQueueViewCell*)[queueView cellForItemAtIndex:index makeIfNecessary:NO];
	if (!item)
		item = (SNRQueueViewCell*)[queueView dequeueReusableCell];
	if (!item)
		item = [[SNRQueueViewCell alloc] init];
    SNRQueueItem *queueItem = [[self queueItems] objectAtIndex:index];
    SNRSong *song = [queueItem song];
    if (song) {
        [item bind:@"artistName" toObject:song withKeyPath:@"rawArtist" options:nil];
        [item bind:@"totalTime" toObject:song withKeyPath:@"duration" options:nil];
        [item bind:@"songName" toObject:song withKeyPath:@"name" options:nil];
    } else {
        return item;
    }
    if (_cachedPlayingIndex != NSNotFound) {
        item.dimmed = index < _cachedPlayingIndex;
    }
    item.queueController = self;
    BOOL nowPlaying = queueItem == self.currentQueueItem;
    [item setNowPlaying:nowPlaying animated:NO];
    if (nowPlaying) {
        item.playbackState = self.playerState == SNRQueueControllerPlayerStatePlaying;
        NSTimeInterval currentTime = _player.currentTime;
        NSTimeInterval totalTime = _player.totalTime;
        item.progressDoubleValue = currentTime;
        item.progressMaxValue = totalTime;
        item.remainingTime = totalTime - currentTime;
    }
    if ([song.album valueForKey:@"artwork"]) {
        if (self.loadArtworkSynchronously) {
            item.image = [_artworkCache synchronousCachedArtworkForObject:song.album artworkSize:[queueView cellSize]];
        } else {
            item.image = [_artworkCache asynchronousCachedArtworkForObject:song.album artworkSize:[queueView cellSize] asyncHandler:^(NSImage *image) {
                SNRQueueViewCell *queueCell = (SNRQueueViewCell*)[queueView cellForItemAtIndex:index makeIfNecessary:NO];
                queueCell.image = image;
            }];
        }
    } else {
        item.image = [NSImage imageNamed:kImageGeneric];
    }
    return item;
}

- (void)queueView:(SNRQueueView*)queueView clickedItemAtIndex:(NSUInteger)index
{
    SNRQueueItem *item = [[self queueItems] objectAtIndex:index];
    if (item != self.currentQueueItem) {
        [self enqueueQueueItem:item];
    }
}

- (void)queueView:(SNRQueueView*)queueView removeItemAtIndex:(NSUInteger)index
{
    [_arrayController removeObjectAtArrangedObjectIndex:index];
}

- (id<NSPasteboardWriting>)queueView:(SNRQueueView*)queueView pasteboardWriterForIndex:(NSInteger)index
{
    return [[[self queueItems] objectAtIndex:index] song];
}

- (void)queueView:(SNRQueueView*)queueView moveItemAtIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    NSMutableArray *items = [[self queueItems] mutableCopy];
    [items moveObjectFromIndex:from to:to];
    [_arrayController setContent:items];
}

- (void)queueView:(SNRQueueView*)queueView insertSongs:(NSArray*)songs atIndex:(NSUInteger)index
{
    NSArray *items = [self playbackItemsForSongs:songs];
    NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(index, [songs count])];
    [_arrayController insertObjects:items atArrangedObjectIndexes:indexes];
}

- (NSView*)viewForNoItemsInQueueView:(SNRQueueView*)queueView
{
    return [[SNRQueueEmptyView alloc] initWithFrame:[[queueView enclosingScrollView] bounds]];
}

- (NSMenu*)queueView:(SNRQueueView*)queueView menuForItemAtIndex:(NSUInteger)index
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Queue"];
    NSArray *queueItems = [self queueItems];
    __weak SNRQueueController *weakSelf = self;
    if (index != NSNotFound) {
        SNRQueueItem *item = [queueItems objectAtIndex:index];
        if (item != self.currentQueueItem) {
            SNRBlockMenuItem *remove = [[SNRBlockMenuItem alloc] initWithTitle:[NSString stringWithFormat:NSLocalizedString(@"RemoveItem", nil), item.song.name] keyEquivalent:@"" block:^(NSMenuItem *item) {
                SNRQueueController *strongSelf = weakSelf;
                [strongSelf->_arrayController removeObjectAtArrangedObjectIndex:index];
            }];
            [menu addItem:remove];
        }
    }
    NSUInteger count = [queueItems count];
    if (count) {
        SNRBlockMenuItem *clear = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString((count > 1) ? @"Clear" : @"StopPlayback", nil)  keyEquivalent:@"" block:^(NSMenuItem *item) {
            SNRQueueController *strongSelf = weakSelf;
            [strongSelf clearQueueImmediately:NO];
        }];
        [menu addItem:clear];
        [menu addItem:[NSMenuItem separatorItem]];
    }
    NSMenuItem *repeatContainer = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"Repeat", nil) action:nil keyEquivalent:@""];
    NSMenu *repeatMenu = [[NSMenu alloc] initWithTitle:@"Repeat"];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    SNRBlockMenuItem *repeatNone = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"RepeatNone", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        [ud setRepeatMode:SNRQueueControllerRepeatModeNone];
    }];
    repeatNone.state = self.repeatMode == SNRQueueControllerRepeatModeNone;
    [repeatMenu addItem:repeatNone];
    SNRBlockMenuItem *repeatAll = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"RepeatAll", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        [ud setRepeatMode:SNRQueueControllerRepeatModeAll];
    }];
    repeatAll.state = self.repeatMode == SNRQueueControllerRepeatModeAll;
    [repeatMenu addItem:repeatAll];
    SNRBlockMenuItem *repeatOne = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"RepeatOne", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        [ud setRepeatMode:SNRQueueControllerRepeatModeOne];
    }];
    repeatOne.state = self.repeatMode == SNRQueueControllerRepeatModeOne;
    [repeatMenu addItem:repeatOne];
    repeatContainer.submenu = repeatMenu;
    [menu addItem:repeatContainer];
    if (count > 1) {
        SNRBlockMenuItem *shuffle = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Shuffle", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
            SNRQueueController *strongSelf = weakSelf;
            [strongSelf shuffle];
        }];
        [menu addItem:shuffle];
    }
    return menu;
}


#pragma mark - Queue Accessors

// --------------------
// Bunch of convenience methods to add songs to the queue
// --------------------

- (NSArray *)playbackItemsForSongs:(NSArray*)songs
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[songs count]];
    for (SNRSong *song in songs) {
        SNRQueueItem *item = [SNRQueueItem new];
        item.song = song;
        [items addObject:item];
    }
    return items;
}

- (void)enqueueSongs:(NSArray*)songs
{
    [_arrayController addObjects:[self playbackItemsForSongs:songs]];
}

- (void)enqueueObjects:(NSArray*)objects
{
    NSMutableArray *songs = [NSMutableArray array];
    for (id object in objects) {
        [songs addObjectsFromArray:[object songsArray]];
    }
    [self enqueueSongs:songs];
}

- (void)enqueueObjectsAndShuffle:(NSArray*)objects
{
    NSMutableArray *songs = [NSMutableArray array];
    for (id object in objects) {
        [songs addObjectsFromArray:[object songsArray]];
    }
    [songs randomize];
    [self enqueueSongs:songs];
}

- (void)playSongs:(NSArray*)songs
{
    [self clearQueueImmediately:YES];
    [self enqueueSongs:songs];
    [self play];
}

- (void)playObjects:(NSArray*)objects
{
    [self clearQueueImmediately:YES];
    [self enqueueObjects:objects];
    [self play];
}

- (void)shuffleSongs:(NSArray*)songs
{
    [self clearQueueImmediately:YES];
    [self enqueueSongs:[songs randomizedArray]];
    [self play];
}

- (void)shuffleObjects:(NSArray*)objects
{
    [self clearQueueImmediately:YES];
    NSMutableArray *songs = [NSMutableArray array];
    for (id object in objects) {
        [songs addObjectsFromArray:[object songsArray]];
    }
    [songs randomize];
    [self enqueueSongs:songs];
    [self play];
}
@end
