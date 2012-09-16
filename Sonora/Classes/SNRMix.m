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

#import "SNRMix.h"
#import "SNRMixArtwork.h"
#import "SNRMixThumbnailArtwork.h"
#import "SNRArtwork.h"
#import "SNRSong.h"
#import "SNRAlbum.h"

#import "SNRSearchIndex-SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"

static NSString* const kImageSearchIcon = @"album-Template";

@implementation SNRMix

#pragma mark - Custom Setters

- (void)setName:(NSString *)name
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:name];
    [self didChangeValueForKey:@"name"];
    [[SNRSearchIndex sharedIndex] updateSearchIndexForSonoraObject:self];
}

- (void)setSongs:(NSOrderedSet *)songs
{
    [self willChangeValueForKey:@"songs"];
    [self setPrimitiveSongs:(NSMutableOrderedSet*)songs];
    [self didChangeValueForKey:@"songs"];
    [self recalculatePopularity];
}

#pragma mark - Popularity

- (void)recalculatePopularity
{
    double popularity = 0.0;
    for (SNRSong *song in self.songs) {
        popularity += song.popularity.doubleValue;
    }
    self.popularity = [NSNumber numberWithDouble:popularity];
}

#pragma mark - Custom Accessors

- (double)duration
{
    double totalDuration = 0.0;
    for (SNRSong *song in self.songs) {
        totalDuration += song.duration.doubleValue;
    }
    return totalDuration;
}

#pragma mark - Artwork

- (NSImage*)artworkImage
{
    NSData *data = self.artwork.data;
    return (data != nil) ? [[NSImage alloc] initWithData:data] : [NSImage imageNamed:kImageGenericArtwork];
}

- (NSImage*)thumbnailArtworkImage
{
    NSData *data = self.thumbnailArtwork.data;
    return (data != nil) ? [[NSImage alloc] initWithData:data] : [NSImage imageNamed:kImageGenericArtworkThumbnail];
}

- (void)setArtworkWithData:(NSData*)data cropped:(BOOL)cropped
{
    NSData *normalArt = [SNRAlbum artworkDataForImageData:data size:NSZeroSize cropped:cropped];
    if (normalArt) {
        NSData *thumbnailArt = [SNRAlbum artworkDataForImageData:data size:kThumbnailArtworkSize cropped:cropped];
        [self setArtworkWithProcessedLargeData:normalArt thumbnailData:thumbnailArt];
    }
}

- (void)setArtworkWithProcessedLargeData:(NSData*)large thumbnailData:(NSData*)thumbnail
{
    NSManagedObjectContext *ctx = self.managedObjectContext;
    if (self.artwork) { [self removeArtwork]; }
    self.artwork = [ctx createObjectOfEntityName:kEntityNameMixArtwork];
    self.artwork.data = large;
    self.thumbnailArtwork = [ctx createObjectOfEntityName:kEntityNameMixThumbnailArtwork];
    self.thumbnailArtwork.data = thumbnail;
}

- (void)removeArtwork
{
    [self.artwork deleteAndPropagateChanges];
    [self.thumbnailArtwork deleteAndPropagateChanges];
}

#pragma mark - Search

- (NSImage*)searchArtwork
{
    return self.thumbnailArtworkImage;
}

- (NSImage*)searchIcon
{
    NSImage *image = [NSImage imageNamed:kImageSearchIcon];
    image.template = YES;
    return image;
}

- (NSString*)searchStatisticText
{
    NSUInteger numberOfSongs = [self.songs count];
    return [NSString stringWithFormat:@"%lu %@", numberOfSongs, NSLocalizedString((numberOfSongs == 1) ? @"song" : @"songs", nil)];
}

#pragma mark - Playback

- (NSArray*)songsArray
{
    return [self.songs array];
}
@end
