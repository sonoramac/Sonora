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

#import "SNRAlbumMetadataViewController.h"
#import "SNRMetadataImageView.h"
#import "SNRAudioMetadata.h"
#import "SNRArtwork.h"
#import "SNRSong.h"
#import "SNRAlbum.h"
#import "SNRArtist.h"

#import "NSDictionary+SNRAdditions.h"
#import "NSWindow+SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"
#import "NSUserDefaults-SNRAdditions.h"

@interface SNRAlbumMetadataViewController ()
- (void)updateUserInterface;
- (void)performBlockIgnoringKVONotifications:(void (^)())block;
- (void)separateCompilationAlbum:(SNRAlbum*)album name:(NSString*)name artist:(NSString*)artist;
@property (nonatomic, copy) NSImage *artwork;
@property (nonatomic, copy) NSString *imageViewPlaceholder;
@end

@implementation SNRAlbumMetadataViewController {
    BOOL _ignoreKVONotifications;
    NSInteger _compilationState;
    NSMutableDictionary *_changedValues;
    NSData *_artworkData;
    BOOL _removedArtwork;
}
@synthesize name = _name;
@synthesize artist = _artist;
@synthesize nameField = _nameField;
@synthesize artistField = _artistField;
@synthesize imageView = _imageView;
@synthesize artwork = _artwork;
@synthesize compilation = _compilation;
@synthesize compilationCheckbox = _compilationCheckbox;
@synthesize imageViewPlaceholder = _imageViewPlaceholder;

- (void)performBlockIgnoringKVONotifications:(void (^)())block
{
    _ignoreKVONotifications = YES;
    if (block) block();
    _ignoreKVONotifications = NO;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.imageView bind:@"image" toObject:self withKeyPath:@"artwork" options:nil];
    [self.imageView bind:@"placeholder" toObject:self withKeyPath:@"imageViewPlaceholder" options:nil];
    [self updateUserInterface];
}

- (id)init
{
    if ((self = [super init])) {
        _changedValues = [NSMutableDictionary dictionary];
        [self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"artist" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"compilation" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"name"];
    [self removeObserver:self forKeyPath:@"artist"];
    [self removeObserver:self forKeyPath:@"compilation"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (_ignoreKVONotifications) { return; }
    id new = [change valueForKey:NSKeyValueChangeNewKey];
    for (SNRSong *song in self.selectedItems) {
        NSMutableDictionary *changeDict = [_changedValues objectForKey:song.objectID];
        if (!changeDict) { changeDict = [NSMutableDictionary dictionary]; }
        [changeDict setObject:new forKey:keyPath];
        [_changedValues setObject:changeDict forKey:song.objectID];
    }
}

- (IBAction)clickedCompilation:(id)sender
{
    if ([[sender selectedCell] state] == NSMixedState){
        [[sender selectedCell] performClick:sender];
    }
}

- (IBAction)done:(id)sender
{
    [self.view.window endEditingPreservingFirstResponder:NO];
    if (![_changedValues count] && !_artworkData && !_removedArtwork) {
        [self cancel:nil];
        return;
    }
    NSArray *items = [NSArray arrayWithArray:self.metadataItems];
    NSDictionary *values = [NSDictionary dictionaryWithDictionary:_changedValues];
    NSManagedObjectContext *context = SONORA_MANAGED_OBJECT_CONTEXT;
    for (SNRAlbum *album in items) {
        NSManagedObjectID *objectID = album.objectID;
        NSDictionary *changes = [values objectForKey:objectID];
        if ([changes count]) {
            NSString *albumName = [changes nilOrValueForKey:@"name"];
            NSString *albumArtist = [changes nilOrValueForKey:@"artist"];
            NSNumber *compilation = [changes nilOrValueForKey:@"compilation"];
            SNRArtist *oldArtist = album.artist;
            SNRArtist *artist = oldArtist;
            SNRAlbum *newAlbum = nil;
            NSArray *songs = [album.songs allObjects];
            if (compilation && [compilation boolValue] != album.compilation) {
                if ([compilation boolValue]) {
                    artist = [context compilationsArtist];
                } else {
                    [self separateCompilationAlbum:album name:albumArtist artist:albumName];
                    return;
                }
            }
            if (albumArtist) {
                if (![albumArtist length]) {
                    albumArtist = NSLocalizedString(@"UntitledArtist", nil);
                }
                if (![albumArtist isEqualToString:oldArtist.name] && ![compilation boolValue]) {
                    artist = [context artistWithName:albumArtist create:YES];
                }
            }
            if (!albumName) {
                albumName = album.name;
            } else if (albumName && ![albumName length]) {
                albumName = NSLocalizedString(@"UntitledAlbum", nil);
            }
            if (![albumName isEqualToString:album.name] || ![oldArtist isEqual:artist]) {
                SNRAlbum *fetchedAlbum = [context albumWithName:albumName byArtist:artist create:NO];
                if (fetchedAlbum && ![fetchedAlbum isEqual:album]) {
                    newAlbum = fetchedAlbum;
                } else {
                    album.artist = artist;
                    album.name = albumName;
                }
            }
            for (SNRSong *song in songs) {
                if (compilation) {
                    song.compilation = compilation;
                }
                if (newAlbum) {
                    song.album = newAlbum;
                }
                song.rawAlbumArtist = albumArtist;
                if (song.iTunesPersistentID) {
                    [[NSUserDefaults standardUserDefaults] showFirstMetadataiTunesAlert];
                } else {
                    SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:song.url];
                    metadata.albumTitle = albumName;
                    metadata.albumArtist = albumArtist;
                    metadata.compilation = song.compilation;
                    [metadata writeMetadata];
                }
            }
            if (newAlbum) {
                [album deleteFromLibraryAndFromDisk:NO];
            }
            if (_artworkData) {
                [newAlbum ?: album setArtworkWithData:_artworkData cropped:YES];
            } else if (_removedArtwork) {
                [newAlbum ?: album removeArtwork];
            }
            if (![oldArtist.albums count]) {
                [oldArtist deleteFromLibraryAndFromDisk:NO];
            }
        } else if (_artworkData) {
            [album setArtworkWithData:_artworkData cropped:YES];
        } else if (_removedArtwork) {
            [album removeArtwork];
        }
    }
    [context saveChanges];
    [self cancel:nil];
}

- (void)separateCompilationAlbum:(SNRAlbum*)album name:(NSString*)name artist:(NSString*)artist
{
    NSArray *songs = [album.songs allObjects];
    NSManagedObjectContext *context = SONORA_MANAGED_OBJECT_CONTEXT;
    NSNumber *compilation = [NSNumber numberWithBool:NO];
    NSMutableArray *artworkAlbums = [NSMutableArray array];
    for (SNRSong *song in songs) {
        song.compilation = compilation;
        NSString *newArtistName = nil;
        if (artist) {
            song.rawAlbumArtist = artist;
            newArtistName = artist;
        } else {
            if (![song.rawAlbumArtist isEqualToString:album.artist.name]) {
                newArtistName = song.rawAlbumArtist ?: song.rawArtist;
            } else {
                newArtistName = song.rawArtist;
            }
        }
        SNRArtist *artist = [context artistWithName:newArtistName create:YES];
        NSString *newAlbumName = album.name;
        if (name) { newAlbumName = name; }
        SNRAlbum *fetchedAlbum = [context albumWithName:newAlbumName byArtist:artist create:YES];
        if ([fetchedAlbum isEqual:album]) { return; }
        if (_artworkData && ![artworkAlbums containsObject:fetchedAlbum]) {
            [fetchedAlbum setArtworkWithData:_artworkData cropped:YES];
            [artworkAlbums addObject:fetchedAlbum];
        } else if (_removedArtwork) {
            [fetchedAlbum removeArtwork];
        }
        song.album = fetchedAlbum;
        if (song.iTunesPersistentID) {
            [[NSUserDefaults standardUserDefaults] showFirstMetadataiTunesAlert];
        } else {
            SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:song.url];
            metadata.albumTitle = newAlbumName;
            metadata.albumArtist = newArtistName;
            metadata.compilation = compilation;
            [metadata writeMetadata];
        }
    }
    [album deleteFromLibraryAndFromDisk:NO];
}

- (void)setSelectedItems:(NSArray *)selectedItems
{
    [super setSelectedItems:selectedItems];
    [_changedValues removeAllObjects];
    _artworkData = nil;
    _removedArtwork = NO;
    _compilationState = 0;
    self.imageViewPlaceholder = nil;
    NSUInteger count = [selectedItems count];
    __block __unsafe_unretained SNRAlbumMetadataViewController *blockSelf = self;
    if (count > 1) {
        SNRAlbum *firstAlbum = [self.selectedItems objectAtIndex:0];
        NSString *artist = firstAlbum.artist.name;
        BOOL compilation = firstAlbum.compilation;
        BOOL useCheckboxMixedState = NO;
        BOOL hasArtwork = firstAlbum.artwork != nil;
        for (NSInteger i = 1; i < count; i++) {
            SNRAlbum *album = [self.selectedItems objectAtIndex:i];
            if (![artist isEqualToString:album.artist.name]) {
                artist = nil;
            }
            if (compilation != album.compilation) {
                useCheckboxMixedState = YES;
            }
            if (!hasArtwork && album.artwork) {
                hasArtwork = YES;
            }
        }
        _compilationState = useCheckboxMixedState ? NSMixedState : compilation;
        self.imageViewPlaceholder = NSLocalizedString(hasArtwork ? @"MultipleAlbumsSelected" : @"DropArtwork", nil);
        [self performBlockIgnoringKVONotifications:^{
            blockSelf.artist = artist;
            blockSelf.artwork = nil;
        }];
    } else if (count) {
        SNRAlbum *album = [self.selectedItems objectAtIndex:0];
        self.imageViewPlaceholder = NSLocalizedString(@"DropArtwork", nil);
        [self performBlockIgnoringKVONotifications:^{
            blockSelf.name = album.name;
            blockSelf.artist = album.artist.name;
            NSData *artwork = album.artwork.data;
            blockSelf.artwork = (artwork != nil) ? [[NSImage alloc] initWithData:artwork] : nil;
            blockSelf.compilation = album.compilation;
        }];
    }
    [self updateUserInterface];
}

- (void)updateUserInterface
{
    if ([self.selectedItems count] > 1) {
        [self.nameField setEnabled:NO];
        __block __unsafe_unretained SNRAlbumMetadataViewController *blockSelf = self;
        [self performBlockIgnoringKVONotifications:^{
            [blockSelf.nameField setStringValue:@""];
            [blockSelf.compilationCheckbox setState:blockSelf->_compilationState];
        }];
    } else {
        [self.nameField setEnabled:YES];
    }
}

- (void)imageView:(SNRMetadataImageView*)imageView droppedImageWithData:(NSData*)data
{
    if (data) {
        _artworkData = [SNRAlbum artworkDataForImageData:data size:NSZeroSize cropped:NO];
    }
    if ([self.selectedItems count] && _artworkData) {
        self.artwork = [[NSImage alloc] initWithData:_artworkData];
    }
}

- (void)imageViewRemovedArtwork:(SNRMetadataImageView*)imageView
{
    _removedArtwork = YES;
    self.imageViewPlaceholder = NSLocalizedString(@"DropArtwork", nil);
}
@end
