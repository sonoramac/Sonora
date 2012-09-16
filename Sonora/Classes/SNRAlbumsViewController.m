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

#import "SNRAlbumsViewController.h"
#import "SNRSongsViewController.h"
#import "SNRArtistsViewController.h"
#import "SNRMetadataWindowController.h"
#import "SNRQueueView.h"
#import "SNRQueueCoordinator.h"
#import "SNRArtwork.h"
#import "SNRAlbum.h"
#import "SNRMixArtwork.h"
#import "SNRBlockMenuItem.h"
#import "SNRArrayController.h"
#import "SNRAlbumsGridView.h"
#import "SNRAlbumEmptyView.h"

#import "NSUserDefaults-SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"

#define kGridViewMinimumItemWidth 128.f
#define kGridViewMaximumItemWidth 700.f

#define kLibrarySegmentIndex 0
#define kMixesSegmentIndex 1

enum {
	SNRAlbumsViewControllerSortModePopular = 0,
	SNRAlbumsViewControllerSortModeNew = 1,
	SNRAlbumsViewControllerSortModeArtist = 2
};
typedef NSInteger SNRAlbumsViewControllerSortMode;

@interface SNRAlbumCopyProgress : NSObject
@property (nonatomic, assign) unsigned long long progress;
@property (nonatomic, assign) unsigned long long total;
@end

@implementation SNRAlbumCopyProgress
@synthesize progress = _progress;
@synthesize total = _total;
@end

@interface SNRAlbumsViewController ()
- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification;
- (NSArray *)albumSortDescriptors;

- (void)downloadArtworkForAlbums:(NSArray*)albums;
- (void)removeArtworkForAlbums:(NSArray*)albums;
- (void)savePlaylistsForMixes:(NSArray*)mixes;
- (void)deleteItems:(NSArray*)items;
@property (nonatomic, retain) NSPopover *popover;
@property (nonatomic, retain) NSArray *artists;
@property (nonatomic, assign) SNRAlbumsViewControllerSortMode sortMode;
@end

@implementation SNRAlbumsViewController {
    SNRArrayController *_arrayController;
    SNRArtworkCache *_artworkCache;
    SNRAlbumEmptyView *_emptyView;
    
    NSIndexSet *_preservedSelectionIndexes;
	NSOperationQueue *_importQueue;
    
    CGFloat _scaledArtworkWidth;
	BOOL _showingMixes;
    BOOL _cellWidthChanged;
    BOOL _ignoreSelectionChanged;
}
@synthesize gridView = _gridView;
@synthesize gridScrollView = _gridScrollView;
@synthesize popover = _popover;
@synthesize cellWidth = _cellWidth;
@synthesize artists = _artists;
@synthesize sortMode = _sortMode;
@synthesize sortControl = _sortControl;
@synthesize widthSlider = _widthSlider;

#pragma mark -
#pragma mark Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder])) {
		_importQueue = [NSOperationQueue new];
        _artworkCache = [SNRArtworkCache new];
        _emptyView = [[SNRAlbumEmptyView alloc] initWithFrame:NSZeroRect];
        [_emptyView setText:NSLocalizedString(@"NoMusic", nil)];
	}
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
    _arrayController = [[SNRArrayController alloc] init];
    [_arrayController setManagedObjectContext:SONORA_MANAGED_OBJECT_CONTEXT];
    [_arrayController setAutomaticallyRearrangesObjects:YES];
    [_arrayController setClearsFilterPredicateOnInsertion:YES];
    [_arrayController setPreservesSelection:YES];
    [_arrayController setEntityName:kEntityNameAlbum];
    [_arrayController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:SONORA_MANAGED_OBJECT_CONTEXT];
    
    [self.gridView setDelegate:self];
    [self.gridView setDataSource:self];
    [self.widthSlider setMinValue:kGridViewMinimumItemWidth];
    [self.widthSlider setMaxValue:kGridViewMaximumItemWidth];
	NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
	[self setCellWidth:[[NSUserDefaults standardUserDefaults] cellWidth]];
	_sortMode = ud.sortMode;
	[self selectionChangedInGridView:self.gridView];
}

- (void)loadView
{
	[super loadView];
	[self setView:self.gridScrollView];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.gridView reloadData];
    _ignoreSelectionChanged = YES;
    [self.gridView setSelectionIndexes:_preservedSelectionIndexes];
    _ignoreSelectionChanged = NO;
}

- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification
{
    NSSet *updated = [[notification userInfo] valueForKey:NSUpdatedObjectsKey];
    NSMutableIndexSet *updateIndexes = [NSMutableIndexSet indexSet];
    for (NSManagedObject *object in updated) {
        NSUInteger index = [[_arrayController arrangedObjects] indexOfObject:object];
        if (index != NSNotFound) {
            NSArray *changedValues = [[object changedValuesForCurrentEvent] allKeys];
            if ([changedValues containsObject:@"artwork"]) {
                [updateIndexes addIndex:index];
                [_artworkCache removeCachedArtworkForObject:object];
            }
        }
    }
    if ([updateIndexes count])
        [self.gridView reloadCellsAtIndexes:updateIndexes];
}

#pragma mark -
#pragma mark Accessors

- (void)setCellWidth:(CGFloat)cellWidth
{
    if (cellWidth != _cellWidth) {
        _cellWidth = cellWidth;
        _scaledArtworkWidth = _cellWidth - ([SNRAlbumGridViewCell selectionInset] * 2.f);
        _cellWidthChanged = YES;
        self.gridView.itemSize = NSMakeSize(_cellWidth, _cellWidth);
        [[NSUserDefaults standardUserDefaults] setCellWidth:_cellWidth];
    }
}

- (void)setSortMode:(SNRAlbumsViewControllerSortMode)sortMode
{
	if (_sortMode != sortMode) {
		_sortMode = sortMode;
        [[NSUserDefaults standardUserDefaults] setSortMode:_sortMode];
        [self.sortControl setSelectedSegment:_sortMode];
		[self reloadData];
	}
}

- (void)setSortControl:(NSSegmentedControl *)sortControl
{
    if (_sortControl != sortControl) {
        _sortControl = sortControl;
        [_sortControl setSelectedSegment:_sortMode];
    }
}

- (IBAction)sortingChanged:(id)sender
{
    self.sortMode = [sender selectedSegment];
}

#pragma mark - Data Management

- (void)reloadDataWithArtists:(NSArray *)artists
{
	NSWindow *window = self.gridView.window;
	[window endEditingFor:window];
	[_artworkCache removeAllCachedArtwork];
	self.artists = artists;
    _showingMixes = NO;
	NSPredicate *basePredicate = [NSPredicate predicateWithFormat:@"artist == $ARTIST"];
    NSMutableArray *subpredicates = [NSMutableArray arrayWithCapacity:[artists count]];
    for (SNRArtist *artist in artists) {
        NSDictionary *variables = [NSDictionary dictionaryWithObject:artist forKey:@"ARTIST"];
        NSPredicate *substituted = [basePredicate predicateWithSubstitutionVariables:variables];
        [subpredicates addObject:substituted];
    }
    _arrayController.entityName = kEntityNameAlbum;
    _arrayController.fetchSortDescriptors = [self albumSortDescriptors];
    _arrayController.fetchPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:subpredicates];
    [_arrayController fetch:nil];
}

- (void)reloadDataWithMixes
{
	NSWindow *window = self.gridView.window;
	[window endEditingFor:window];
	[_artworkCache removeAllCachedArtwork];
    _showingMixes = YES;
    
    _arrayController.entityName = kEntityNameMix;
    _arrayController.fetchSortDescriptors = [self albumSortDescriptors];
	_arrayController.fetchPredicate = nil;
    [_arrayController fetch:nil];
}

- (NSArray *)albumSortDescriptors
{
	NSSortDescriptor *popularity = [NSSortDescriptor sortDescriptorWithKey:kSortPopularityKey ascending:NO];
	NSSortDescriptor *date = [NSSortDescriptor sortDescriptorWithKey:kSortDateModifiedKey ascending:NO];
	NSSortDescriptor *artist = [NSSortDescriptor sortDescriptorWithKey:kSortArtistKey ascending:YES];
	NSSortDescriptor *name = [NSSortDescriptor sortDescriptorWithKey:kSortNameKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)];
	NSArray *descriptors = nil;
	switch (self.sortMode) {
		case SNRAlbumsViewControllerSortModeNew:
			if (_showingMixes)
				descriptors = [NSArray arrayWithObjects:date, popularity, name, nil];
			else
				descriptors = [NSArray arrayWithObjects:date, popularity, artist, name, nil];
			break;
		case SNRAlbumsViewControllerSortModeArtist:
            if (_showingMixes)
                descriptors = [NSArray arrayWithObjects:name, popularity, date, nil];
            else
                descriptors = [NSArray arrayWithObjects:artist, name, popularity, date, nil];
			break;
		case SNRAlbumsViewControllerSortModePopular:
			if (_showingMixes)
				descriptors = [NSArray arrayWithObjects:popularity, date, name, nil];
			else
				descriptors = [NSArray arrayWithObjects:popularity, date, artist, name, nil];
			break;
		default:
			break;
	}
	return descriptors;
}

- (void)reloadData
{
	_showingMixes ? [self reloadDataWithMixes] : [self reloadDataWithArtists:self.artists];
}

#pragma mark - OEGridViewDataSource

- (NSUInteger)numberOfItemsInGridView:(OEGridView *)gridView
{
	return [[_arrayController arrangedObjects] count];
}

- (OEGridViewCell *)gridView:(OEGridView *)gridView cellForItemAtIndex:(NSUInteger)index
{
	SNRAlbumGridViewCell *item = (SNRAlbumGridViewCell *)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
	if (!item)
		item = (SNRAlbumGridViewCell *)[gridView dequeueReusableCell];
	if (!item)
		item = [[SNRAlbumGridViewCell alloc] init];
	id object = [[_arrayController arrangedObjects] objectAtIndex:index];
    item.representedObject = object;
    item.delegate = self;
    item.image = [_artworkCache asynchronousCachedArtworkForObject:object artworkSize:NSMakeSize(_scaledArtworkWidth, _scaledArtworkWidth) asyncHandler:^(NSImage *image) {
        SNRAlbumGridViewCell *gridCell = (SNRAlbumGridViewCell*)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
        if (image) gridCell.image = image;
    }];
    item.displayGenericArtwork = ([object valueForKey:@"artwork"] == nil);
	return item;
}

#pragma mark - OEGridViewDelegate

- (void)selectionChangedInGridView:(OEGridView *)gridView
{
    if (_ignoreSelectionChanged) { return; }
    _preservedSelectionIndexes = [gridView selectionIndexes];
	NSArray *albums = _showingMixes ? nil : [[_arrayController arrangedObjects] objectsAtIndexes:gridView.selectionIndexes];
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:kEntityNameAlbum, SNRMetadataWindowControllerSelectionChangedEntityNameKey, albums, SNRMetadataWindowControllerSelectionChangedItemsKey, nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:SNRMetadataWindowControllerSelectionChangedNotification object:self userInfo:userInfo];
}

- (id<NSPasteboardWriting>)gridView:(OEGridView *)gridView pasteboardWriterForIndex:(NSInteger)index
{
    return [[_arrayController arrangedObjects] objectAtIndex:index];
}

- (void)gridView:(OEGridView *)gridView doubleClickedCellForItemAtIndex:(NSUInteger)index
{
	if (self.popover) { [self.popover close]; }
	id anItem = [[_arrayController arrangedObjects] objectAtIndex:index];
	if (![[anItem songs] count]) { return; }
	self.popover = [[NSPopover alloc] init];
	SNRSongsViewController *content = [[SNRSongsViewController alloc] initWithContainer:anItem];
	content.popover = self.popover;
	self.popover.contentViewController = content;
	self.popover.behavior = NSPopoverBehaviorSemitransient;
	self.popover.contentSize = [SNRSongsViewController sizeForContainer:anItem];
	
	SNRAlbumGridViewCell *cell = (SNRAlbumGridViewCell*)[gridView cellForItemAtIndex:index makeIfNecessary:NO];
	NSRect rect = NSZeroRect;
	if ([cell superlayer] != [gridView layer]) {
		CGRect baseLayerRect = [cell convertRect:cell.bounds toLayer:[gridView layer]];
		rect = [gridView convertRectFromLayer:NSRectFromCGRect(baseLayerRect)];
	} else {
		rect = [gridView convertRectFromLayer:rect];
	}
	[self.popover showRelativeToRect:rect ofView:gridView preferredEdge:NSMaxXEdge];
}

- (void)gridView:(OEGridView *)gridView magnifiedWithEvent:(NSEvent*)event
{
	CGFloat magnification = [event magnification];
	CGFloat widthChange = self.cellWidth * magnification;
	self.cellWidth = MIN(MAX(round(self.cellWidth + widthChange), kGridViewMinimumItemWidth), kGridViewMaximumItemWidth);
}

- (void)gridView:(OEGridView *)gridView magnifyEndedWithEvent:(NSEvent*)event
{
    if (_cellWidthChanged) {
        [_artworkCache removeAllCachedArtwork];
        [self.gridView reloadData];
    }
    _cellWidthChanged = NO;
}

- (NSMenu*)gridView:(OEGridView *)gridView menuForItemsAtIndexes:(NSIndexSet*)indexSet
{
	NSArray *albums = [[_arrayController arrangedObjects] objectsAtIndexes:indexSet];
	if ([albums count]) {
		SNRQueueController *controller = SNR_MainQueueController;
		BOOL isAlbum = [[albums objectAtIndex:0] isKindOfClass:[SNRAlbum class]];
		NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Albums"];
		SNRBlockMenuItem *play = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Play", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
            [controller playObjects:albums];
		}];
		[menu addItem:play];
		SNRBlockMenuItem *enqueue = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Enqueue", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
			[controller enqueueObjects:albums];
		}];
		[menu addItem:enqueue];
		SNRBlockMenuItem *shuffle = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Shuffle", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
			[controller shuffleObjects:albums];
		}];
		[menu addItem:shuffle];
		__block __unsafe_unretained SNRAlbumsViewController *bself = self;
		SNRBlockMenuItem *delete = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
			[bself deleteItems:albums];
		}];
		[menu addItem:delete];
		BOOL artworkExists = NO;
		BOOL artworkDownloadable = YES;
		for (id album in albums) {
			if ([album isKindOfClass:[SNRAlbum class]]) {
				artworkExists = [album artwork] != nil;
			} else if ([album isKindOfClass:[SNRMix class]]) {
				artworkDownloadable = NO;
				artworkExists = [album artwork] && ![[(SNRMixArtwork*)[album artwork] generated] boolValue]; 
			}
			if (artworkExists) { break; }
		}
		if (isAlbum || artworkExists || artworkDownloadable) {
			[menu addItem:[NSMenuItem separatorItem]];
		}
		if (isAlbum) {
			SNRBlockMenuItem *edit = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"EditMetadata", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
				[[SNRMetadataWindowController sharedWindowController] showWindow:nil];
			}];
			[menu addItem:edit];
		}
		if (artworkExists) {
			SNRBlockMenuItem *removeArtwork = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"RemoveArtwork", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
				[self removeArtworkForAlbums:albums];
			}];
			[menu addItem:removeArtwork];
		}
		if (artworkDownloadable) {
			SNRBlockMenuItem *downloadArtwork = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"DownloadArtwork", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
				[self downloadArtworkForAlbums:albums];
			}];
			[menu addItem:downloadArtwork];
		}
		if (!isAlbum) {
			[menu addItem:[NSMenuItem separatorItem]];
			SNRBlockMenuItem *m3u = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"ExportM3U", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
                [self savePlaylistsForMixes:albums];
            }];
			[menu addItem:m3u];
		}
		return menu;
	}
	return nil;
}

- (void)gridView:(OEGridView *)gridView deleteItemsAtIndexes:(NSIndexSet*)indexes
{
    NSArray *albums = [[_arrayController arrangedObjects] objectsAtIndexes:indexes];
    if ([albums count]) {
        [self deleteItems:albums];
    }
}

- (NSDragOperation)gridView:(OEGridView *)gridView validateDrop:(id<NSDraggingInfo>)sender
{
    return [(id)[self.gridView window] draggingEntered:sender];
}

- (BOOL)gridView:(OEGridView *)gridView acceptDrop:(id<NSDraggingInfo>)sender
{
    return [(id)[self.gridView window] performDragOperation:sender];
}

- (NSDragOperation)gridView:(OEGridView *)gridView draggingUpdated:(id<NSDraggingInfo>)sender
{
    return [(id)[self.gridView window] draggingUpdated:sender];
}

- (NSView *)viewForNoItemsInGridView:(OEGridView *)gridView
{
    [_emptyView setFrame:[[gridView enclosingScrollView] bounds]];
    return _emptyView;
}

#pragma mark - SNRAlbumGridViewCellDelegate

- (void)albumGridViewCell:(SNRAlbumGridViewCell*)cell acceptedArtworkImageData:(NSData*)artworkData originalImageData:(NSData*)original
{
    NSData *thumbnailData = [SNRAlbum artworkDataForImageData:original size:kThumbnailArtworkSize cropped:NO];
    [cell.representedObject setArtworkWithProcessedLargeData:artworkData thumbnailData:thumbnailData];
    cell.image = [_artworkCache synchronousCachedArtworkForObject:cell.representedObject artworkSize:NSMakeSize(_scaledArtworkWidth, _scaledArtworkWidth)];
    [[cell.representedObject managedObjectContext] saveChanges];
}

#pragma mark - Memory Management

- (void)dealloc
{
    [_arrayController removeObserver:self forKeyPath:@"arrangedObjects"];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private

- (void)removeArtworkForAlbums:(NSArray *)albums
{
    for (id album in albums) {
        [album removeArtwork];
    }
    [SONORA_MANAGED_OBJECT_CONTEXT saveChanges];
}

- (void)savePlaylistsForMixes:(NSArray*)mixes
{
    NSMutableArray *paths = [NSMutableArray array];
    for (SNRMix *mix in mixes) {
        [paths addObjectsFromArray:[[[mix.songs array] valueForKey:@"url"] valueForKey:@"path"]];
    }
    NSString *m3uContents = [paths componentsJoinedByString:@"\n"];
    NSSavePanel *savePanel = [NSSavePanel savePanel];
    [savePanel setTitle:NSLocalizedString(@"SaveM3U", nil)];
    [savePanel setCanCreateDirectories:YES];
    [savePanel setAllowsOtherFileTypes:NO];
    [savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"m3u"]];
    [savePanel setNameFieldStringValue:@"Untitled.m3u"];
    [savePanel setExtensionHidden:NO];
    [savePanel setCanSelectHiddenExtension:YES];
    NSInteger result = [savePanel runModal];
    if (result == NSFileHandlingPanelOKButton) {
        NSError *error = nil;
        [m3uContents writeToURL:[savePanel URL] atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (error) {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
        }
    }
}

- (void)downloadArtworkForAlbums:(NSArray*)albums
{
    for (SNRAlbum *album in albums) {
        [album removeArtwork];
        [album setDidSearchForArtwork:[NSNumber numberWithBool:NO]];
        NSUInteger index = [[_arrayController arrangedObjects] indexOfObject:album];
        [_artworkCache asynchronousCachedArtworkForObject:album artworkSize:NSMakeSize(_scaledArtworkWidth, _scaledArtworkWidth) asyncHandler:^(NSImage *image) {
            SNRAlbumGridViewCell *gridCell = (SNRAlbumGridViewCell*)[self.gridView cellForItemAtIndex:index makeIfNecessary:NO];
            gridCell.image = image;
        }];
    }
}

- (void)deleteItems:(NSArray*)items
{
	BOOL isAlbum = [[items objectAtIndex:0] isKindOfClass:[SNRAlbum class]];
	BOOL useOtherButton = YES;
	if (isAlbum) {
		for (SNRAlbum *album in items) {
			useOtherButton = [album isDeletableFromDisk];
			if (!useOtherButton) { break; }
		}
	}
	NSString *title = NSLocalizedString(isAlbum ? (useOtherButton ? @"DeleteAlertTitle" : @"DeleteAlertAlternateTitle") : @"DeleteMixAlertTitle", nil);
	NSString *defaultButton = NSLocalizedString(isAlbum ? (useOtherButton ? @"DeleteAlertDefaultButton" : @"DeleteAlertAlternateDefaultButton") : @"DeleteMixAlertDefaultButton", nil);
	NSString *alternateButton = NSLocalizedString(isAlbum ? @"DeleteAlertAlternateButton" : @"DeleteMixAlertAlternateButton", nil);
	NSString *otherButton = isAlbum ? (useOtherButton ? NSLocalizedString(@"DeleteAlertOtherButton", nil) : nil) : nil;
	NSAlert *alert = [NSAlert alertWithMessageText:title defaultButton:defaultButton alternateButton:alternateButton otherButton:otherButton informativeTextWithFormat:@""];
	NSInteger response = [alert runModal];
	if (response != NSAlertAlternateReturn) {
		if (isAlbum) {
			for (SNRAlbum *album in items) {
				[album deleteFromLibraryAndFromDisk:(response == NSAlertOtherReturn)];
			}
		} else {
			for (SNRMix *mix in items) {
				[mix deleteFromContextAndSearchIndex];
			}
		}
		[SONORA_MANAGED_OBJECT_CONTEXT saveChanges];
	}
}
@end

