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

#import "SNRSong.h"
#import "SNRAlbum.h"
#import "SNRArtist.h"
#import "SNRPlayCount.h"
#import "SNRQueueView.h"
#import "SNRMix.h"

#import "SNRSearchIndex-SNRAdditions.h"
#import "NSString-SNRAdditions.h"
#import "NSWorkspace+SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"

static NSString* const kImageSearchIcon = @"song-Template";

@implementation SNRSong

#pragma mark - Custom Accessors

- (void)setName:(NSString *)name
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:name];
    [self didChangeValueForKey:@"name"];
    [[SNRSearchIndex sharedIndex] updateSearchIndexForSonoraObject:self];
}

- (BOOL)setBookmarkWithPath:(NSString*)path
{
    NSError *error = nil;
    NSURL *url = [NSURL fileURLWithPath:path];
    NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
    if (error || !bookmark) { 
        NSLog(@"Error creating bookmark for song at path %@: %@, %@", path, error, [error userInfo]);
        return NO; 
    }
    self.bookmark = bookmark;
    return YES;
}

- (NSString*)durationString
{
	return [NSString timeStringForTimeInterval:[self.duration doubleValue]];
}

- (NSString*)displayArtistName
{
    return self.rawArtist ?: self.rawAlbumArtist;
}

- (NSURL*)url
{
    if (self.bookmark) {
        NSError *error = nil;
        NSURL *url = [NSURL URLByResolvingBookmarkData:self.bookmark options:0 relativeToURL:nil bookmarkDataIsStale:NULL error:&error];
        if (error) {
            NSLog(@"Error while resolving URL for song %@: %@ %@", self, error, [error userInfo]);
        }
        return url;
    }
    return nil;
}

- (void)setDateAdded:(NSDate*)value
{
    [self willChangeValueForKey:@"dateAdded"];
    [self setPrimitiveDateAdded:value];
    [self didChangeValueForKey:@"dateAdded"];
    self.album.dateModified = value;
}

- (void)setAlbum:(SNRAlbum *)album
{
    double songPopularity = self.popularity.doubleValue;
    double oldPopularity = self.album.popularity.doubleValue - songPopularity;
    self.album.popularity = [NSNumber numberWithDouble:oldPopularity];
    [self willChangeValueForKey:@"album"];
    [self setPrimitiveAlbum:album];
    [self didChangeValueForKey:@"album"];
    double newPopularity = album.popularity.doubleValue + songPopularity;
    self.album.popularity = [NSNumber numberWithDouble:newPopularity];
}

- (void)addPlayCountsObject:(SNRPlayCount *)value
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self modifyPopularityByAddingPlayCounts:changedObjects];
    [self willChangeValueForKey:@"playCounts"
                withSetMutation:NSKeyValueUnionSetMutation
                   usingObjects:changedObjects];
    [[self primitivePlayCounts] addObject:value];
    [self didChangeValueForKey:@"playCounts"
               withSetMutation:NSKeyValueUnionSetMutation
                  usingObjects:changedObjects];
}

- (void)addPlayCounts:(NSSet *)value
{
    [self willChangeValueForKey:@"playCounts"
                withSetMutation:NSKeyValueUnionSetMutation
                   usingObjects:value];
    [[self primitivePlayCounts] unionSet:value];
    [self didChangeValueForKey:@"playCounts"
               withSetMutation:NSKeyValueUnionSetMutation
                  usingObjects:value];
    [self modifyPopularityByAddingPlayCounts:value];
}

#pragma mark - Deletion


- (void)deleteFromLibraryAndFromDisk:(BOOL)disk
{
    double popularity = self.popularity.doubleValue;
    if (popularity) {
        [self modifyPopularityWithValue:-popularity];
    }
    if (disk) {
        [[NSWorkspace sharedWorkspace] moveFileToTrash:self.url.path];
    }
    SNRAlbum *album = self.album;
    [album removeSongsObject:self];
    [self deleteFromContextAndSearchIndex];
    if (![album.songs count]) {
        [album deleteFromContextAndSearchIndex];
    }
}

- (BOOL)isDeletableFromDisk
{
    return (self.iTunesPersistentID == nil);
}

#pragma mark - Search

- (NSImage*)searchArtwork
{
    return self.album.thumbnailArtworkImage;
}

- (NSImage*)searchIcon
{
    NSImage *image = [NSImage imageNamed:kImageSearchIcon];
    image.template = YES;
    return image;
}

- (NSString*)searchStatisticText
{
    return self.durationString;
}

- (NSString*)searchSubtitleText
{
    return self.album.artist.name;
}

#pragma mark - Play Counts and Popularity

- (void)modifyPopularityWithValue:(double)value
{
    double songPopularity = [self.popularity doubleValue];
    double albumPopularity = [self.album.popularity doubleValue];
    songPopularity += value;
    albumPopularity += value;
    self.popularity = [NSNumber numberWithDouble:songPopularity];
    self.album.popularity = [NSNumber numberWithDouble:albumPopularity];
    for (SNRMix *mix in self.mixes) {
        double mixPopularity = [mix.popularity doubleValue] + value;
        mix.popularity = [NSNumber numberWithDouble:mixPopularity];
    }
}

- (double)popularityForPlayCounts:(NSSet*)playCounts
{
    double popularityIndex = 0.0;
    for (SNRPlayCount *playCount in playCounts) {
        NSTimeInterval interval = [playCount.date timeIntervalSinceReferenceDate];
        popularityIndex += interval/kNumberOfSecondsPerDay;
    }
    return popularityIndex;
}

- (void)modifyPopularityByAddingPlayCounts:(NSSet*)playCounts
{
    double value = [self popularityForPlayCounts:playCounts];
    [self modifyPopularityWithValue:value];
}

- (void)addPlayCountObjectWithDate:(NSDate*)date
{
    if (!date) { date = [NSDate date]; }
    SNRPlayCount *count = [self.managedObjectContext createObjectOfEntityName:kEntityNamePlayCount];
    count.date = date;
    [self addPlayCountsObject:count];
}

- (NSArray*)songsArray
{
    return [NSArray arrayWithObject:self];
}

#pragma mark - Pasteboard Writing

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    NSURL *songURL = self.url;
    if (songURL ) { [pasteboard writeObjects:[NSArray arrayWithObject:songURL]]; }
    return [NSArray arrayWithObject:SNRQueueSongsDragIdentifier];
}

- (id)pasteboardPropertyListForType:(NSString *)type
{
    if ([type isEqualToString:SNRQueueSongsDragIdentifier]) {
        return [NSKeyedArchiver archivedDataWithRootObject:[NSArray arrayWithObject:[[self objectID] URIRepresentation]]];
    }
    return nil;
}

@end
