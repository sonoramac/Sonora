//
//  SNRQueueItem.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRQueueItem.h"
#import "SNRThumbnailArtwork.h"

#import "SNRLastFMEngine-SNRAdditions.h"
#import "NSUserDefaults-SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"

@implementation SNRQueueItem
@synthesize played = _played;
@synthesize song = _song;

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    SNRQueueItem *item = [[SNRQueueItem allocWithZone:zone] init];
    item->_song = _song;
    return item;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super init])) {
        NSURL *URL = [aDecoder decodeObjectForKey:@"song"];
        if (URL) {
            NSManagedObjectContext *context = SONORA_MANAGED_OBJECT_CONTEXT;
            NSManagedObjectID *objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:URL];
            if (objectID) {
                _song = (SNRSong*)[context existingObjectWithID:objectID error:nil];
                if (!_song) {
                    return nil;
                }
            } else {
                return nil;
            }
        }
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    NSURL *URI = [[self.song objectID] URIRepresentation];
    [aCoder encodeObject:URI forKey:@"song"];
}

#pragma mark - Accessors

- (void)setPlayed:(BOOL)played
{
    if (_played != played) {
        _played = played;
        if (!_played) { return; }
        SNRLastFMEngine *engine = [SNRLastFMEngine sharedInstance];
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if ([engine isAuthenticated] && ud.scrobble) {
            [engine scrobbleSong:self.song];
        }
        [self.song addPlayCountObjectWithDate:[NSDate date]];
        [self.song.managedObjectContext saveChanges];
    }
}

#pragma mark - Public API

- (void)lastFMUpdateNowPlaying
{
    SNRLastFMEngine *engine = [SNRLastFMEngine sharedInstance];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if ([engine isAuthenticated] && ud.scrobble) {
        [engine updateNowPlayingWithSong:self.song];
    }
}

- (void)lastFMLoveTrack
{
    SNRLastFMEngine *engine = [SNRLastFMEngine sharedInstance];
    if ([engine isAuthenticated]) {
        [engine loveSong:self.song];
    }
}

- (void)postGrowlNotification
{
    if ([[NSUserDefaults standardUserDefaults] growlNowPlaying]) {
        [GrowlApplicationBridge notifyWithTitle:self.song.name description:self.song.album.artist.name notificationName:kGrowlNotificationNowPlaying iconData:self.song.album.thumbnailArtwork.data priority:0 isSticky:NO clickContext:@"" identifier:kGrowlNotificationNowPlaying];
    }
}


@end