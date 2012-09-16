#import "SNRArtist.h"
#import "SNRAlbum.h"
#import "SNRSong.h"

#import "SNRSearchIndex-SNRAdditions.h"
#import "NSArray-SNRAdditions.h"
#import "NSString-SNRAdditions.h"
#import "NSWorkspace+SNRAdditions.h"

static NSString* const kImageSearchIcon = @"artist-Template";

@implementation SNRArtist

#pragma mark - Search

- (NSImage*)searchArtwork
{
    NSImage *artwork = nil;
    for (SNRAlbum *album in self.albums) {
        artwork = album.thumbnailArtworkImage;
        if (artwork) { break; }
    }
    return (artwork != nil) ? artwork : [NSImage imageNamed:kImageGenericArtworkThumbnail];
}

- (NSImage*)searchIcon
{
    NSImage *image = [NSImage imageNamed:kImageSearchIcon];
    image.template = YES;
    return image;
}

- (NSString*)searchStatisticText
{
    NSUInteger numberOfAlbums = [self.albums count];
    return [NSString stringWithFormat:@"%lu %@", numberOfAlbums, NSLocalizedString((numberOfAlbums == 1) ? @"album" : @"albums", nil)];
}

#pragma mark - Custom Accessors

- (void)setName:(NSString *)name
{
    [self willChangeValueForKey:@"name"];
    [self setPrimitiveName:name];
    [self didChangeValueForKey:@"name"];
    if (name) {
        self.sortingName = [[self class] sortNameForArtistName:name];
    } else {
        self.sortingName = nil;
    }
    for (SNRAlbum *album in self.albums) {
        if (!album.artwork && [album.didSearchForArtwork boolValue]) {
            album.didSearchForArtwork = [NSNumber numberWithBool:NO];
        }
    }
    [[SNRSearchIndex sharedIndex] updateSearchIndexForSonoraObject:self];
}

+ (NSString*)sortNameForArtistName:(NSString*)artistName
{
    NSArray *filterTerms = [NSArray arrayWithObjects:@"the ", @"a ", @"an ", nil];
    NSMutableString *sortString = [NSMutableString stringWithString:artistName];
    for (NSString *term in filterTerms) {
        NSRange range = [sortString rangeOfString:term options:NSCaseInsensitiveSearch];
        if ((range.location == 0) && (range.length > 0)) {
            [sortString replaceCharactersInRange:range withString:@""];
            break;
        }
    }
    return [sortString normalizedString];
}

#pragma mark - Deletion

- (void)deleteFromLibraryAndFromDisk:(BOOL)disk
{
    NSArray *albumArray = [self.albums allObjects];
    for (SNRAlbum *album in albumArray) {
        NSArray *songArray = [album.songs allObjects];
        for (SNRSong *song in songArray) {
            if (disk) {
                [[NSWorkspace sharedWorkspace] moveFileToTrash:song.url.path];
            }
            [song deleteFromContextAndSearchIndex];
        }
        [album deleteFromContextAndSearchIndex];
    }
    [self deleteFromContextAndSearchIndex];
}

- (BOOL)isDeletableFromDisk
{
    for (SNRAlbum *album in self.albums) {
        for (SNRSong *song in album.songs) {
            if (song.iTunesPersistentID) {
                return NO;
            }
        }
    }
    return YES;
}

#pragma mark - Playback

- (NSArray*)songsArray
{
    NSMutableArray *songs = [NSMutableArray array];
    for (SNRAlbum *album in self.albums) {
        [songs addObjectsFromArray:[album.songs allObjects]];
    }
    [songs randomize];
    return songs;
}
@end
