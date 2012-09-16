//
//  SNRArtistsViewController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-03.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtistsViewController.h"
#import "SNRAlbumsViewController.h"
#import "SNRArtistTableRowView.h"
#import "SNRArtistHeaderTableRowView.h"
#import "SNRQueueView.h"
#import "SNRBlockMenuItem.h"
#import "SNRAudioMetadata.h"
#import "SNRArrayController.h"
#import "SNRQueueCoordinator.h"

#import "NSTableView-SNRAdditions.h"
#import "NSOutlineView+SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"
#import "NSUserDefaults-SNRAdditions.h"

#import "SNRArtistsStaticGroupNode.h"
#import "SNRArtistsArrayControllerNode.h"

static NSString* const kMainCellIdentifier = @"ArtistMainCell";
static NSString* const kHeaderCellIdentifier = @"ArtistHeaderCell";
static NSString* const kRestorationKeySelectedArtists = @"selectedArtists";
static NSString* const kExpandSidebarIdleNotification = @"SNRExpandSidebarIdleNotification";

#define kMainCellRowHeight 30.f
#define kHeaderCellRowHeight 26.f

@interface SNRArtistsViewController ()
- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification;
- (void)resetStaticGroupNodeAttributes;

- (void)deleteItems:(NSArray*)items;
- (NSArray*)artistsForStaticNode:(SNRArtistsStaticNode*)node;

- (IBAction)doubleClickedOutlineView:(id)sender;
@end

@implementation SNRArtistsViewController {
    SNRArrayController *_arrayController;
    SNRArtistsStaticGroupNode *_staticGroupNode;
    SNRArtist *_compilationsArtist;
    NSArray *_content;
    BOOL _awakenFromNib;
}
@synthesize outlineView = _outlineView;
@synthesize albumsViewController = _albumsViewController;

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (_awakenFromNib) { return; }
    [self.outlineView setTarget:self];
    [self.outlineView setDoubleAction:@selector(doubleClickedOutlineView:)];
    [self.outlineView setFloatsGroupRows:NO];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(managedObjectContextObjectsDidChange:) name:NSManagedObjectContextObjectsDidChangeNotification object:SONORA_MANAGED_OBJECT_CONTEXT];
    [nc addObserver:self selector:@selector(expandSidebar) name:kExpandSidebarIdleNotification object:nil];
    _awakenFromNib = YES;
}

#pragma mark - Public API

- (void)reloadData
{
    NSManagedObjectContext *managedObjectContext = SONORA_MANAGED_OBJECT_CONTEXT;
    _compilationsArtist = [managedObjectContext compilationsArtist];
    _arrayController = [[SNRArrayController alloc] init];
    [_arrayController setManagedObjectContext:managedObjectContext];
    [_arrayController setEntityName:kEntityNameArtist];
    [_arrayController setFetchSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSortSortNameKey ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]];
    [_arrayController setFetchPredicate:[NSPredicate predicateWithFormat:@"(albums.@count != 0) AND (SELF != %@)", _compilationsArtist]];
    [_arrayController setAutomaticallyRearrangesObjects:YES];
    [_arrayController setClearsFilterPredicateOnInsertion:YES];
    [_arrayController setPreservesSelection:YES];
    [_arrayController addObserver:self forKeyPath:@"arrangedObjects" options:0 context:NULL];
    [_arrayController addObserver:self forKeyPath:@"selectionIndexes" options:0 context:NULL];
    [_arrayController fetch:nil];
    
    _staticGroupNode = [[SNRArtistsStaticGroupNode alloc] init];
    _staticGroupNode.name = NSLocalizedString(@"Collections", nil);
    _staticGroupNode.groupNode = YES;
    [self resetStaticGroupNodeAttributes];
    
    SNRArtistsArrayControllerNode *arrayNode = [[SNRArtistsArrayControllerNode alloc] initWithArrayController:_arrayController];
    arrayNode.groupNode = YES;
    arrayNode.name = NSLocalizedString(@"Artists", nil);
    _content = [NSArray arrayWithObjects:_staticGroupNode, arrayNode, nil];
    [self.outlineView reloadData];
    [self postExpandNotification];
}

- (void)resetStaticGroupNodeAttributes
{
    NSManagedObjectContext *managedObjectContext = SONORA_MANAGED_OBJECT_CONTEXT;
    _staticGroupNode.showMixes = [managedObjectContext numberOfMixes] != 0;
    _staticGroupNode.showCompilations = [[[managedObjectContext compilationsArtist] albums] count] != 0;
}

/* Expand sidebar hack implementation as outlined here <http://happygiraffe.net/blog/2008/03/30/expanding-outline-views-in-cocoa/> */

- (void)postExpandNotification
{
    NSNotification* todo = [NSNotification notificationWithName:kExpandSidebarIdleNotification object:self];
    [[NSNotificationQueue defaultQueue] enqueueNotification:todo postingStyle:NSPostWhenIdle];
}

- (void)expandSidebar
{
    [self.outlineView expandItem:nil expandChildren:YES];
    [self selectArtist:nil];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"arrangedObjects"]) {
        [self.outlineView reloadData];
        [self postExpandNotification];
    } else if ([keyPath isEqualToString:@"selectionIndexes"]) {
        if (![[self.outlineView selectedRowIndexes] count]) { [self selectArtist:nil]; }
    }
}

#pragma mark - Memory Management

- (void)dealloc
{
    [_arrayController removeObserver:self forKeyPath:@"arrangedObjects"];
    [_arrayController removeObserver:self forKeyPath:@"selectionIndexes"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Notifications

- (void)selectArtist:(id)artist
{
    NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:1];
    if (artist) {
        // Hack to map the static node to the right object
        if ([artist isKindOfClass:[SNRArtistsStaticNode class]]) {
            switch ([(SNRArtistsStaticNode *)artist type]) {
                case SNRArtistsStaticNodeTypeAlbums:
                    artist = _staticGroupNode.albums;
                    break;
                case SNRArtistsStaticNodeTypeMixes:
                    artist = _staticGroupNode.mixes;
                    break;
                case SNRArtistsStaticNodeTypeCompilations:
                    artist = _staticGroupNode.compilations;
                    break;
                default:
                    break;
            }
        }
        NSInteger row = [self.outlineView rowForItem:artist];
        if (row != -1)
            indexSet = [NSIndexSet indexSetWithIndex:row];
    }
    [self.outlineView selectRowIndexes:indexSet byExtendingSelection:NO];
}

- (BOOL)hasStaticNodeWithType:(SNRArtistsStaticNodeType)type
{
    switch (type) {
        case SNRArtistsStaticNodeTypeAlbums:
            return YES;
        case SNRArtistsStaticNodeTypeCompilations:
            return _staticGroupNode.showCompilations;
        case SNRArtistsStaticNodeTypeMixes:
            return _staticGroupNode.showMixes;
        default:
            return NO;
    }
}

- (void)managedObjectContextObjectsDidChange:(NSNotification*)notification
{
    BOOL resetNodeAttributes = NO;
    NSDictionary *userInfo = [notification userInfo];
    NSSet *inserted = [userInfo valueForKey:NSInsertedObjectsKey];
    NSSet *deleted = [userInfo valueForKey:NSDeletedObjectsKey];
    NSManagedObjectContext *context = SONORA_MANAGED_OBJECT_CONTEXT;
    if (!_staticGroupNode.showMixes || !_staticGroupNode.showCompilations) {
        for (NSManagedObject *object in inserted) {
            if (!_staticGroupNode.showMixes && [object isKindOfClass:[SNRMix class]]) {
                _staticGroupNode.showMixes = YES;
                resetNodeAttributes = YES;
            } else if (!_staticGroupNode.showCompilations && [object isKindOfClass:[SNRAlbum class]]) {
                if ([[object valueForKey:@"artist"] isEqual:_compilationsArtist]) {
                    _staticGroupNode.showCompilations = YES;
                    resetNodeAttributes = YES;
                }
            }
            if (_staticGroupNode.showMixes && _staticGroupNode.showCompilations)
                break;
        }
    }
    if (_staticGroupNode.showMixes || _staticGroupNode.showCompilations) {
        for (NSManagedObject *object in deleted) {
            if (_staticGroupNode.showMixes && [object isKindOfClass:[SNRMix class]]) {
                if (![context numberOfMixes]) {
                    _staticGroupNode.showMixes = NO;
                    resetNodeAttributes = YES;
                }
            } else if (_staticGroupNode.showCompilations && [object isKindOfClass:[SNRAlbum class]]) {
                if ([[object valueForKey:@"artist"] isEqual:_compilationsArtist] && ![[_compilationsArtist albums] count]) {
                    _staticGroupNode.showCompilations = NO;
                    resetNodeAttributes = YES;
                }
            }
            if (!_staticGroupNode.showMixes && !_staticGroupNode.showCompilations)
                break;
        }
    }
    if (resetNodeAttributes) {
        [self resetStaticGroupNodeAttributes];
        [self.outlineView reloadData];
    }
}

#pragma mark - NSTableViewDataSource

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if (!item) {
        return [_content objectAtIndex:index];
    } else if ([item isKindOfClass:[SNRArtistsNode class]]) {
        return [[item children] objectAtIndex:index];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ([item isKindOfClass:[SNRArtistsNode class]]) {
        return [[item children] count] != 0;
    }
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if (!item) {
        return [_content count];
    } else if ([item isKindOfClass:[SNRArtistsNode class]]) {
        return [[item children] count];
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    return item;
}

- (id<NSPasteboardWriting>)outlineView:(NSOutlineView *)outlineView pasteboardWriterForItem:(id)item
{
    if ([item conformsToProtocol:@protocol(NSPasteboardWriting)]) {
        return item;
    }
    return nil;
}

#pragma mark - NSOutlineVieWDelegate

- (NSTableRowView *)outlineView:(NSOutlineView *)outlineView rowViewForItem:(id)item
{
    if ([self outlineView:outlineView isGroupItem:item]) {
        return [[SNRArtistHeaderTableRowView alloc] initWithFrame:NSZeroRect];
    } else {
        SNRArtistTableRowView *rowView = [[SNRArtistTableRowView alloc] initWithFrame:NSZeroRect];
        NSUInteger nextRow = [outlineView rowForItem:item] + 1;
        rowView.hideSeparator = nextRow < [self.outlineView numberOfRows] && [[self.outlineView itemAtRow:nextRow] isKindOfClass:[SNRArtistsArrayControllerNode class]];
        return rowView;
    }
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    return [self outlineView:outlineView isGroupItem:item] ? kHeaderCellRowHeight : kMainCellRowHeight;
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    BOOL groupRow = [self outlineView:outlineView isGroupItem:item];
    NSTableCellView *view = [outlineView makeViewWithIdentifier:groupRow ? kHeaderCellIdentifier : kMainCellIdentifier owner:self];
    [view.textField setEditable:[item isKindOfClass:[SNRArtist class]]];
    return view;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    if ([self outlineView:outlineView isGroupItem:item]) { return NO; }
    NSIndexSet *indexes = [outlineView selectedRowIndexes];
    BOOL itemIsArtist = [item isKindOfClass:[SNRArtist class]];
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        id object = [outlineView itemAtRow:idx];
        if ([object isKindOfClass:[SNRArtistsNode class]] || ([object isKindOfClass:[SNRArtist class]] && !itemIsArtist)) {
            [outlineView deselectAll:nil];
            *stop = YES;
        }
    }];
    return YES;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    if ([item isKindOfClass:[SNRArtistsNode class]]) { return [item isGroupNode]; }
    return NO;
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    NSIndexSet *indexes = [self.outlineView selectedRowIndexes];
    NSMutableArray *artists = [NSMutableArray array];
    __block BOOL reloadingMixes = NO;
    [indexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        id object = [self.outlineView itemAtRow:idx];
        if ([object isKindOfClass:[SNRArtistsStaticNode class]]) {
            if ([(SNRArtistsStaticNode *)object type]==SNRArtistsStaticNodeTypeMixes) {
                [self.albumsViewController reloadDataWithMixes];
                reloadingMixes = YES;
                *stop = YES;
            } else {
                [artists addObjectsFromArray:[self artistsForStaticNode:object]];
            }
        } else if ([object isKindOfClass:[SNRArtist class]]) {
            [artists addObject:object];
        }
    }];
    if (!reloadingMixes) {
        [self.albumsViewController reloadDataWithArtists:artists];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
    return NO;
}

#pragma mark - Convenience

- (NSArray*)artistsForStaticNode:(SNRArtistsStaticNode*)node
{
    SNRArtistsStaticNodeType type = [node type];
    if (type == SNRArtistsStaticNodeTypeAlbums) {
        return [_arrayController arrangedObjects];
    } else if (type == SNRArtistsStaticNodeTypeCompilations) {
        return [NSArray arrayWithObject:_compilationsArtist];
    }
    return [NSArray array];
}

#pragma mark - NSMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    [menu removeAllItems];
    NSIndexSet *indexes = [self.outlineView clickedAndSelectedRowIndexes];
    NSArray *objects = [self.outlineView itemsAtRowIndexes:indexes];
    NSMutableArray *artists = [NSMutableArray array];
    BOOL itemsAreDeletable = YES;
    for (id object in objects) {
        if ([object isKindOfClass:[SNRArtistsNode class]]) {
            itemsAreDeletable = NO;
            if ([object isKindOfClass:[SNRArtistsStaticNode class]]) {
                [artists addObjectsFromArray:[self artistsForStaticNode:object]];
            }
        } else if ([object isKindOfClass:[SNRArtist class]]) {
            [artists addObject:object];
        }
    }
    if ([artists count]) {
        SNRQueueController *controller = SNR_MainQueueController;
        if ([artists count]) {
            SNRBlockMenuItem *shuffle = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Shuffle", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
                [controller shuffleObjects:artists];
            }];
            [menu addItem:shuffle];
            SNRBlockMenuItem *enqueue = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Enqueue", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
                [controller enqueueObjectsAndShuffle:artists];
            }];
            [menu addItem:enqueue];
        }
        if (itemsAreDeletable) {
            __block __unsafe_unretained SNRArtistsViewController *bself = self;
            SNRBlockMenuItem *delete = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
                [bself deleteItems:artists];
            }];
            [menu addItem:delete];
        }
    }
}

- (void)tableView:(NSTableView*)aTableView deleteRowsAtIndexes:(NSIndexSet*)indexes
{
    NSArray *items = [self.outlineView itemsAtRowIndexes:indexes];
    for (id object in items) {
        if ([object isKindOfClass:[SNRArtistsNode class]])
            return;
    }
    [self deleteItems:items];
}

- (void)deleteItems:(NSArray*)items
{
    BOOL useOtherButton = YES;
    for (SNRArtist *artist in items) {
        useOtherButton = [artist isDeletableFromDisk];
        if (!useOtherButton) { break; }
    }
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(useOtherButton ? @"DeleteAlertTitle" : @"DeleteAlertAlternateTitle", nil) defaultButton:NSLocalizedString(useOtherButton ? @"DeleteAlertDefaultButton" : @"DeleteAlertAlternateDefaultButton", nil) alternateButton:NSLocalizedString(@"DeleteAlertAlternateButton", nil) otherButton:useOtherButton ? NSLocalizedString(@"DeleteAlertOtherButton", nil) : nil informativeTextWithFormat:@""];
    NSInteger response = [alert runModal];
    if (response != NSAlertAlternateReturn) {
        for (SNRArtist *artist in items) {
            [artist deleteFromLibraryAndFromDisk:(response == NSAlertOtherReturn)];
        }
        [SONORA_MANAGED_OBJECT_CONTEXT saveChanges];
    }
}

- (IBAction)doubleClickedOutlineView:(id)sender
{
    NSInteger clickedRow = [self.outlineView clickedRow];
    if (clickedRow != -1) {
        id object = [self.outlineView itemAtRow:clickedRow];
        NSArray *artists = nil;
        if ([object isKindOfClass:[SNRArtist class]]) {
            artists = [NSArray arrayWithObject:object];
        } else if ([object isKindOfClass:[SNRArtistsStaticNode class]]) {
            artists = [self artistsForStaticNode:object];
        }
        if ([artists count]) {
            [SNR_MainQueueController shuffleObjects:artists];
        }
    }
}

#pragma mark - NSControlTextEditingDelegate
#pragma mark - Metadata

- (IBAction)textFieldEndedEditing:(id)sender
{
    NSInteger row = [self.outlineView rowForView:sender];
    if (row == -1) { return; }
    SNRArtist *artist = [self.outlineView itemAtRow:row];
    if (![artist isKindOfClass:[SNRArtist class]]) { return; }
    NSString *name = [sender stringValue];
    if (![name length]) {
        name = NSLocalizedString(@"UntitledArtist", nil);
    }
    if (![name isEqualToString:artist.name]) {
        NSManagedObjectContext *context = artist.managedObjectContext;
        SNRArtist *fetchedArtist = [context artistWithName:name create:NO];
        if (!fetchedArtist) { artist.name = name; }
        SNRArtist *newArtist = fetchedArtist ?: artist;
        for (SNRAlbum *album in [artist.albums allObjects]) {
            album.artist = newArtist;
            for (SNRSong *song in album.songs) {
                song.rawAlbumArtist = newArtist.name;
                if (song.iTunesPersistentID) {
                    [[NSUserDefaults standardUserDefaults] showFirstMetadataiTunesAlert];
                } else {
                    SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:song.url];
                    metadata.albumArtist = newArtist.name;
                    [metadata writeMetadata];
                }
            }
        }
        if (fetchedArtist) {
            [artist deleteFromLibraryAndFromDisk:NO];
        }
        [context saveChanges];
    }
}
@end
