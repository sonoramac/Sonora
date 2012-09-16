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
