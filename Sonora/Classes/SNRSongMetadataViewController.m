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

#import "SNRSongMetadataViewController.h"
#import "SNRAudioMetadata.h"
#import "SNRSong.h"
#import "SNRAlbum.h"
#import "SNRArtist.h"
#import "SNRClickActionTextField.h"

#import "NSDictionary+SNRAdditions.h"
#import "NSString-SNRAdditions.h"
#import "NSWindow+SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"
#import "NSUserDefaults-SNRAdditions.h"

NSString* const SNRSongMetadataViewControllerSelectedObjectNotification = @"SNRSongMetadataViewControllerSelectedObjectNotification";
NSString* const SNRSongMetadataViewControllerSelectedObjectObjectKey = @"object";

#define kTabViewInfoIndex 0
#define kTabViewPropertiesIndex 1
#define kTabViewLyricsIndex 2
#define kLayoutInfoViewHeight 218.f
#define kLayoutPropertiesViewHeight 191.f
#define kLayoutLyricsViewHeight 300.f

@interface SNRSongMetadataViewController ()
- (void)postSelectedObjectNotification;
- (void)setCurrentSongWithIndex:(NSInteger)index;
- (void)updateUserInterface;
- (void)performBlockIgnoringKVONotifications:(void (^)())block;
@end

@implementation SNRSongMetadataViewController {
    NSMutableDictionary *_changedValues;
    BOOL _ignoreKVONotifications;
}
@synthesize name = _name;
@synthesize trackNumber = _trackNumber;
@synthesize album = _album;
@synthesize discNumber = _discNumber;
@synthesize artist = _artist;
@synthesize playCounts = _playCounts;
@synthesize format = _format;
@synthesize size = _size;
@synthesize bitRate = _bitRate;
@synthesize nextButton = _nextButton;
@synthesize previousButton = _previousButton;
@synthesize segmentedControl = _segmentedControl;
@synthesize tabView = _tabView;
@synthesize pathField = _pathField;
@synthesize path = _path;
@synthesize lyrics = _lyrics;
@synthesize nameField = _nameField;
@synthesize albumField = _albumField;
@synthesize trackField = _trackField;
@synthesize discField = _discField;
@synthesize artistField = _artistField;

#pragma mark - Key Value Observation

- (id)init
{
    if ((self = [super init])) {
        _changedValues = [[NSMutableDictionary alloc] init];
        [self addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"trackNumber" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"album" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"discNumber" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"artist" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"compilation" options:NSKeyValueObservingOptionNew context:NULL];
        [self addObserver:self forKeyPath:@"lyrics" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"album"];
    [self removeObserver:self forKeyPath:@"artist"];
    [self removeObserver:self forKeyPath:@"name"];
    [self removeObserver:self forKeyPath:@"trackNumber"];
    [self removeObserver:self forKeyPath:@"discNumber"];
    [self removeObserver:self forKeyPath:@"compilation"];
    [self removeObserver:self forKeyPath:@"lyrics"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (_ignoreKVONotifications) { return; }
    id new = [change valueForKey:NSKeyValueChangeNewKey];
    if ([new isKindOfClass:[NSAttributedString class]]) {
        new = [new string];
    }
    for (SNRSong *song in self.selectedItems) {
        NSMutableDictionary *changeDict = [_changedValues objectForKey:song.objectID];
        if (!changeDict) { changeDict = [NSMutableDictionary dictionary]; }
        [changeDict setObject:new forKey:keyPath];
        [_changedValues setObject:changeDict forKey:song.objectID];
    }
}

- (void)performBlockIgnoringKVONotifications:(void (^)())block
{
    _ignoreKVONotifications = YES;
    if (block) block();
    _ignoreKVONotifications = NO;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    __block __unsafe_unretained SNRSongMetadataViewController *blockSelf = self;
    self.pathField.mouseUpBlock = ^(void){
        NSString *path = blockSelf.pathField.stringValue;
        if (path) {
            [[NSWorkspace sharedWorkspace] selectFile:path inFileViewerRootedAtPath:nil];;
        }
    };
    NSAttributedString *empty = [[NSAttributedString alloc] initWithString:@""];
    [self.trackField.formatter setAttributedStringForZero:empty];
    [self.discField.formatter setAttributedStringForZero:empty];
    [self updateUserInterface];
}

- (void)updateUserInterface
{
    if ([self.selectedItems count] > 1) {
        [self.segmentedControl setSelectedSegment:0];
        [self segmentChanged:self.segmentedControl];
        [self.segmentedControl setEnabled:NO forSegment:1];
        [self.segmentedControl setEnabled:NO forSegment:2];
        __block __unsafe_unretained SNRSongMetadataViewController *blockSelf = self;
        [self performBlockIgnoringKVONotifications:^{
            [blockSelf.trackField setIntegerValue:0];
            [blockSelf.nameField setStringValue:@""];
        }];
        [self.nameField setEnabled:NO];
        [self.trackField setEnabled:NO];
        [self.previousButton setHidden:YES];
        [self.nextButton setHidden:YES];
        if (!self.artist) {
            [[self.artistField cell] setPlaceholderString:NSLocalizedString(@"MultipleSelectionPlaceholder", nil)];
        }
        if (!self.album) {
            [[self.albumField cell] setPlaceholderString:NSLocalizedString(@"MultipleSelectionPlaceholder", nil)];
        }
    } else {
        [self.segmentedControl setEnabled:YES forSegment:1];
        [self.segmentedControl setEnabled:YES forSegment:2];
        [self.nameField setEnabled:YES];
        [self.trackField setEnabled:YES];
        [self.previousButton setHidden:NO];
        [self.nextButton setHidden:NO];
    }
    
}

#pragma mark - Accessors

- (void)setMetadataItems:(NSArray *)metadataItems selectedIndex:(NSNumber *)index
{
    [_changedValues removeAllObjects];
    [super setMetadataItems:metadataItems selectedIndex:index];
}

- (void)setSelectedItems:(NSArray *)selectedItems
{
    [super setSelectedItems:selectedItems];
    NSUInteger count = [selectedItems count];
    __block __unsafe_unretained SNRSongMetadataViewController *blockSelf = self;
    if (count > 1) {
        SNRSong *firstSong = [selectedItems objectAtIndex:0];
        NSDictionary *changes = [_changedValues objectForKey:firstSong.objectID];
        NSString *artist = [changes nilOrValueForKey:@"artist"] ?: firstSong.rawArtist;
        NSString *album = [changes nilOrValueForKey:@"album"] ?: firstSong.album.name;
        NSNumber *disc = [changes nilOrValueForKey:@"discNumber"] ?: firstSong.discNumber;
        for (NSInteger i = 1; i < count; i++) {
            SNRSong *song = [selectedItems objectAtIndex:i];
            changes = [_changedValues objectForKey:song.objectID];
            if (![artist isEqualToString:[changes nilOrValueForKey:@"artist"] ?: song.rawArtist]) {
                artist = nil; 
            }
            if (![album isEqualToString:[changes nilOrValueForKey:@"album"] ?: song.album.name]) { 
                album = nil; 
            }
            if (![disc isEqualToNumber:[changes nilOrValueForKey:@"discNumber"] ?: song.discNumber]) {
                disc = nil; 
            }
        }
        [self performBlockIgnoringKVONotifications:^{
            blockSelf.artist = artist;
            blockSelf.album = album;
            blockSelf.discNumber = disc;
        }];
    } else if (count) {
        SNRSong *currentSong = [selectedItems objectAtIndex:0];
        NSDictionary *changes = [_changedValues objectForKey:currentSong.objectID];
        [self performBlockIgnoringKVONotifications:^{
            blockSelf.name = [changes nilOrValueForKey:@"name"] ?: currentSong.name;
            blockSelf.trackNumber = [changes nilOrValueForKey:@"trackNumber"] ?: currentSong.trackNumber;
            blockSelf.album = [changes nilOrValueForKey:@"album"] ?: currentSong.album.name;
            blockSelf.discNumber = [changes nilOrValueForKey:@"discNumber"] ?: currentSong.discNumber;
            blockSelf.artist = [changes nilOrValueForKey:@"artist"] ?: currentSong.rawArtist;
            if (currentSong.lyrics) {
                NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont systemFontOfSize:11.f], NSFontAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, nil];
                blockSelf.lyrics = [[NSAttributedString alloc] initWithString:[changes nilOrValueForKey:@"lyrics"] ?: currentSong.lyrics attributes:attributes];
            } else {
                blockSelf.lyrics = nil;
            }
        }];
        NSURL *url = currentSong.url;
        NSNumber *fileSizeBytes;
        [url getResourceValue:&fileSizeBytes forKey:NSURLFileSizeKey error:nil];
        self.size = [NSString stringFromFileSize:[fileSizeBytes unsignedIntegerValue]];
        self.playCounts = [NSNumber numberWithUnsignedInteger:[currentSong.playCounts count]];
        SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:url];
        NSNumber *bitRate = metadata.bitrate;
        self.bitRate = [NSString stringWithFormat:@"%ld kbps", bitRate.integerValue];
        self.format = metadata.formatName;
        self.path = [url path];
    }
    [self updateUserInterface];
}

- (void)setCurrentSongWithIndex:(NSInteger)index
{
    [self.view.window endEditingPreservingFirstResponder:NO];
    NSUInteger count = [self.metadataItems count];
    if (count && index >= 0 && index < count) {
        self.selectedItems = [NSArray arrayWithObject:[self.metadataItems objectAtIndex:index]];
        [self.previousButton setEnabled:index > 0];
        [self.nextButton setEnabled:index < (count - 1)];
    } else {
        self.selectedItems = nil;
        [self.previousButton setEnabled:NO];
        [self.nextButton setEnabled:NO];
    }
}

#pragma mark - Button Actions

- (IBAction)previous:(id)sender
{
    [self setCurrentSongWithIndex:[self.metadataItems indexOfObjectIdenticalTo:[self.selectedItems objectAtIndex:0]] - 1];
    [self postSelectedObjectNotification];
}

- (IBAction)next:(id)sender
{
    [self setCurrentSongWithIndex:[self.metadataItems indexOfObjectIdenticalTo:[self.selectedItems objectAtIndex:0]] + 1];
    [self postSelectedObjectNotification];
}

- (void)postSelectedObjectNotification
{
    if ([self.selectedItems count] == 1) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[self.selectedItems objectAtIndex:0] forKey:SNRSongMetadataViewControllerSelectedObjectObjectKey];
        [[NSNotificationCenter defaultCenter] postNotificationName:SNRSongMetadataViewControllerSelectedObjectNotification object:self userInfo:userInfo];
    }
}

- (IBAction)done:(id)sender
{
    [self.view.window endEditingPreservingFirstResponder:NO];
    if (![_changedValues count]) {
        [self cancel:nil];
        return;
    }
    NSArray *items = [NSArray arrayWithArray:self.metadataItems];
    NSDictionary *values = [NSDictionary dictionaryWithDictionary:_changedValues];
    NSManagedObjectContext *context = SONORA_MANAGED_OBJECT_CONTEXT;
    for (SNRSong *song in items) {
        BOOL writeMetadata = song.iTunesPersistentID == nil;
        NSManagedObjectID *objectID = song.objectID;
        NSDictionary *changes = [values objectForKey:objectID];
        if ([changes count]) {
            BOOL changedArtist = NO;
            NSString *newAlbum = nil;
            SNRAudioMetadata *metadata = writeMetadata ? [[SNRAudioMetadata alloc] initWithFileAtURL:song.url] : nil;
            for (NSString *key in changes) {
                id value = [changes nilOrValueForKey:key];
                if ([key isEqualToString:@"artist"]) {
                    song.rawArtist = value;
                    metadata.artist = value;
                    changedArtist = YES;
                } else if ([key isEqualToString:@"album"]) {
                    metadata.albumTitle = value;
                    newAlbum = value;
                } else if ([key isEqualToString:@"name"]) {
                    if (![value length]) {
                        value = NSLocalizedString(@"UntitledSong", nil);
                    }
                    song.name = value;
                    metadata.title = value;
                } else {
                    [song setValue:value forKey:key];
                    [metadata setValue:value forKey:key];
                }
            }
            [metadata writeMetadata];
            if (!metadata) {
                [[NSUserDefaults standardUserDefaults] showFirstMetadataiTunesAlert];
            }
            SNRAlbum *oldAlbum = song.album;
            SNRAlbum *album = oldAlbum;
            SNRArtist *artist = album.artist;
            if (changedArtist && !song.rawAlbumArtist) {
                NSString *newArtist = song.rawArtist;
                if (!newArtist.length) { 
                    newArtist = NSLocalizedString(@"UntitledArtist", nil); 
                }
                if (![newArtist isEqualToString:artist.name]) {
                    artist = [context artistWithName:newArtist create:YES];
                    if (!newAlbum) {
                        album = [context albumWithName:oldAlbum.name byArtist:artist create:YES];
                    }
                }
            }
            if (newAlbum) {
                if (!newAlbum.length) {
                    newAlbum = NSLocalizedString(@"UntitledAlbum", nil);
                }
                if (![artist isEqual:song.album.artist] || ![newAlbum isEqualToString:album.name]) {
                    album = [context albumWithName:newAlbum byArtist:artist create:YES];
                }
            }
            if (![album isEqual:oldAlbum]) {
                song.album = album;
                if (![oldAlbum.songs count]) {
                    [oldAlbum deleteFromLibraryAndFromDisk:NO];
                }
            }
            
        }
    }
    [context saveChanges];
    [self cancel:nil];
}

- (IBAction)segmentChanged:(id)sender
{
    NSInteger segment = [sender selectedSegment];
    [self.tabView selectTabViewItemAtIndex:segment];
    CGFloat newHeight = 0.0;
    switch (segment) {
        case kTabViewInfoIndex:
            newHeight = kLayoutInfoViewHeight;
            break;
        case kTabViewPropertiesIndex:
            newHeight = kLayoutPropertiesViewHeight;
            break;
        case kTabViewLyricsIndex:
            newHeight = kLayoutLyricsViewHeight;
            break;
        default:
            break;
    }
    NSWindow *window = [self.view window];
    NSRect viewRect = NSMakeRect(0.f, 0.f, self.view.bounds.size.width, newHeight);
    NSRect frame = [window frameRectForContentRect:viewRect];
    NSRect newFrame = window.frame;
    newFrame.origin.y += (newFrame.size.height - frame.size.height);
    newFrame.size.height = frame.size.height;
    [window setFrame:newFrame display:YES animate:YES];
}
@end
