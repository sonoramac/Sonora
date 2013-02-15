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
        [GrowlApplicationBridge notifyWithTitle:self.song.name description:self.song.album.artist.name notificationName:kGrowlNotificationNowPlaying iconData:self.song.album.thumbnailArtworkData priority:0 isSticky:NO clickContext:@"" identifier:kGrowlNotificationNowPlaying];
    }
}


@end