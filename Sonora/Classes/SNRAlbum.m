#import "SNRAlbum.h"
#import "SNRArtwork.h"
#import "SNRThumbnailArtwork.h"
#import "SNRSong.h"
#import "SNRAudioMetadata.h"

#import "NSManagedObjectContext-SNRAdditions.h"
#import "NSUserDefaults-SNRAdditions.h"
#import "SNRSearchIndex-SNRAdditions.h"
#import "NSImage+MGCropExtensions.h"
#import "NSWorkspace+SNRAdditions.h"

static NSString* const kImageSearchIcon = @"album-Template";

@implementation SNRAlbum

#pragma mark - Custom Accessors

- (void)setName:(NSString *)name
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:name];
    [self didChangeValueForKey:@"name"];
    if (!self.artwork && [self.didSearchForArtwork boolValue]) {
        self.didSearchForArtwork = [NSNumber numberWithBool:NO];
    }
    [[SNRSearchIndex sharedIndex] updateSearchIndexForSonoraObject:self];
}

- (void)setArtist:(SNRArtist *)artist
{
    [self willChangeValueForKey:@"artist"];
    [self setPrimitiveArtist:artist];
    [self didChangeValueForKey:@"artist"];
    if (!self.artwork && [self.didSearchForArtwork boolValue]) {
        self.didSearchForArtwork = [NSNumber numberWithBool:NO];
    }
}

- (double)duration
{
    double totalDuration = 0.0;
    for (SNRSong *song in self.songs) {
        totalDuration += song.duration.doubleValue;
    }
    return totalDuration;
}

- (BOOL)isCompilation
{
    return [self.artist isEqual:[self.managedObjectContext compilationsArtist]];
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
    self.artwork = [ctx createObjectOfEntityName:kEntityNameArtwork];
    self.artwork.data = large;
    self.thumbnailArtwork = [ctx createObjectOfEntityName:kEntityNameThumbnailArtwork];
    self.thumbnailArtwork.data = thumbnail;
    if ([[NSUserDefaults standardUserDefaults] embedArtwork]) {
        for (SNRSong *song in self.songs) {
            if (song.iTunesPersistentID) {
                [[NSUserDefaults standardUserDefaults] showFirstMetadataiTunesAlert];
            } else {
                SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:song.url];
                metadata.frontCoverArtData = large;
                [metadata writeMetadata];
            }
        }
    }
}

- (void)removeArtwork
{
    [self.artwork deleteAndPropagateChanges];
    [self.thumbnailArtwork deleteAndPropagateChanges];
}

+ (NSData*)artworkDataForImageData:(NSData*)data size:(CGSize)size cropped:(BOOL)cropped
{
    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc] initWithData:data];
    if (!rep) { return nil; }
    NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize(rep.pixelsWide, rep.pixelsHigh)];
    [image addRepresentation:rep];
    NSImage *crop = image;
    if (!cropped) { 
        CGFloat cropLength = MIN(image.size.width, image.size.height);
        crop = [image imageCroppedToFitSize:NSMakeSize(cropLength, cropLength)];
    }
    NSImage *scaled = NSEqualSizes(size, NSZeroSize) ? crop : [crop imageScaledToFitSize:size];
    NSBitmapImageRep *bitmapRep = [NSBitmapImageRep imageRepWithData:[scaled TIFFRepresentation]];
    return [bitmapRep representationUsingType:NSJPEGFileType properties:nil];
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

- (NSString*)searchSubtitleText
{
    return self.artist.name;
}

#pragma mark - Playback

- (NSArray*)songsArray
{
    NSArray *descriptors = [NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSortDiscNumberKey ascending:YES], [NSSortDescriptor sortDescriptorWithKey:kSortTrackNumberKey ascending:YES], nil];
    return [self.songs sortedArrayUsingDescriptors:descriptors];
}

#pragma mark - Deletion

- (void)deleteFromLibraryAndFromDisk:(BOOL)disk
{
    NSArray *songArray = self.songsArray;
    for (SNRSong *song in songArray) {
        if (disk) {
            [[NSWorkspace sharedWorkspace] moveFileToTrash:song.url.path];
        }
        [song deleteFromContextAndSearchIndex];
    }
    SNRArtist *artist = self.artist;
    [artist removeAlbumsObject:self];
    [self deleteFromContextAndSearchIndex];
    if (![artist.albums count]) {
        [artist deleteFromContextAndSearchIndex];
    }
}

- (BOOL)isDeletableFromDisk
{
    for (SNRSong *song in self.songs) {
        if (song.iTunesPersistentID) {
            return NO;
        }
    }
    return YES;
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

@end
