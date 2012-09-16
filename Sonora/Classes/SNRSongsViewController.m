//
//  SNRSongsViewController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-04.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRSongsViewController.h"
#import "SNRSongTableCellView.h"
#import "SNRQueueView.h"
#import "SNRBlockMenuItem.h"
#import "SNRQueueCoordinator.h"
#import "SNRAudioMetadata.h"
#import "NSTableView-SNRAdditions.h"
#import "SNRMetadataWindowController.h"
#import "SNRSongMetadataViewController.h"
#import "SNRHUDTooltipWindow.h"
#import "SNRArrayController.h"

#import "NSManagedObjectContext-SNRAdditions.h"
#import "NSShadow-SNRAdditions.h"
#import "NSUserDefaults-SNRAdditions.h"

#define kTableViewCellTextFieldLightDefaultColor [NSColor colorWithDeviceWhite:0.64f alpha:1.f]
#define kTableViewCellTextFieldDarkDefaultColor [NSColor blackColor]
#define kTableViewCellTextFieldDefaultFont [NSFont systemFontOfSize:13.f]
#define kTableViewCellTextFieldSmallFont [NSFont systemFontOfSize:11.f]
#define kTableViewCellTextFieldBoldFont [NSFont boldSystemFontOfSize:13.f]
#define kTableViewCellTextFieldSelectedColor [NSColor whiteColor]
#define kTableViewCellTextShadowColor [NSColor colorWithDeviceWhite:0.f alpha:0.5f]
#define kTableViewCellTextShadowOffset NSMakeSize(0.f, -1.f)
#define kTableViewCellTextShadowBlurRadius 2.f

#define kEvenRowColor [NSColor colorWithDeviceWhite:0.95f alpha:1.f]
#define kOddRowColor [NSColor colorWithDeviceWhite:0.93f alpha:1.f]

#define kTableViewCompactCellHeight 30.f
#define kTableViewSubtitleCellHeight 38.f
#define kTableViewMaxNumberOfCompactCells 15
#define kTableViewMaxNumberOfSubtitleCells 10
#define kTableViewDefaultWidth 310.f

static NSString* const kMainCellCompactIdentifier = @"SongMainCompactCell";
static NSString* const kMainCellSubtitleCellIdentifier = @"SongMainSubtitleCell";
static NSString* const kMixCellIdentifier = @"SongMixCell";

@interface SNRSongsViewController ()
- (void)tableViewDoubleClick:(id)sender;
- (void)deleteItems:(NSArray*)items;
- (void)adjustSelectionHighlightForCellView:(SNRSongTableCellView*)view selected:(BOOL)selected;
- (void)adjustSelectionHighlightForVisibleCells;
- (void)selectedObject:(NSNotification*)notification;
@end

@implementation SNRSongsViewController {
    id _container;
    BOOL _blockMetadataNotifications;
    BOOL _selectionChanging;
    BOOL _awakenFromNib;
    SNRHUDTooltipWindow *_tooltipWindow;
}
@synthesize tableView = _tableView;
@synthesize popover = _popover;
@synthesize arrayController = _arrayController;

- (id)initWithContainer:(id)container
{
    if ((self = [super initWithNibName:NSStringFromClass([self class]) bundle:nil])) {
        _container = container;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedObject:) name:SNRSongMetadataViewControllerSelectedObjectNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (_awakenFromNib) { return; }
    self.tableView.target = self;
    self.tableView.doubleAction = @selector(tableViewDoubleClick:);
    [[self.tableView enclosingScrollView] setBackgroundColor:kEvenRowColor];
    [self.arrayController setManagedObjectContext:SONORA_MANAGED_OBJECT_CONTEXT];
    if ([_container isKindOfClass:[SNRAlbum class]]) {
        [self.arrayController setFetchPredicate:[NSPredicate predicateWithFormat:@"album == %@", _container]];
        [self.arrayController setFetchSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor sortDescriptorWithKey:kSortDiscNumberKey ascending:YES], [NSSortDescriptor sortDescriptorWithKey:kSortTrackNumberKey ascending:YES], nil]];
        [self.arrayController fetch:nil];
    } else if ([_container isKindOfClass:[SNRMix class]]) {
        SNRMix *mix = (SNRMix*)_container;
        [self.arrayController setContent:[[mix songs] array]];
    }
    _awakenFromNib = YES;
}

#pragma mark - Accessors

- (void)setPopover:(NSPopover *)popover
{
    if (_popover != popover) {
        _popover = popover;
        _popover.delegate = self;
    }
}

#pragma mark - NSPopoverDelegate

- (void)popoverDidClose:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:SNRMetadataWindowControllerSelectionChangedNotification object:self userInfo:[NSDictionary dictionaryWithObject:kEntityNameSong forKey:SNRMetadataWindowControllerSelectionChangedEntityNameKey]];
}

#pragma mark - Notifications

- (void)selectedObject:(NSNotification*)notification
{
    SNRSong *song = [[notification userInfo] valueForKey:SNRSongMetadataViewControllerSelectedObjectObjectKey];
    if (song) {
        NSUInteger index = [[self.arrayController arrangedObjects] indexOfObject:song];
        if (index != NSNotFound) {
            _blockMetadataNotifications = YES;
            [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:index] byExtendingSelection:NO];
            [self.tableView scrollRowToVisibleAnimated:index];
            _blockMetadataNotifications = NO;
        }
    }
}

#pragma mark - Layout

+ (NSSize)sizeForContainer:(id)container
{
    SNRArtist *compilationsArtist = [SONORA_MANAGED_OBJECT_CONTEXT compilationsArtist];
	BOOL useSubtitle = [container isKindOfClass:[SNRMix class]] || ([container isKindOfClass:[SNRAlbum class]] &&[[container artist] isEqual:compilationsArtist]);
    NSUInteger max = useSubtitle ? kTableViewMaxNumberOfSubtitleCells : kTableViewMaxNumberOfCompactCells;
    NSUInteger rows = MIN(max, [[container songs] count]);
    CGFloat height = useSubtitle ? kTableViewSubtitleCellHeight : kTableViewCompactCellHeight;
    return NSMakeSize(kTableViewDefaultWidth, (rows * height));
}

#pragma mark -
#pragma mark NSTableViewDelegate

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    SNRSongTableCellView *cell = nil;
    SNRSong *song = [[self.arrayController arrangedObjects] objectAtIndex:row];
    if ([_container isKindOfClass:[SNRMix class]]) {
        cell = [tableView makeViewWithIdentifier:kMixCellIdentifier owner:self];
        cell.trackNumberField.integerValue = row + 1;
    } else if ([[_container artist] isEqual:[SONORA_MANAGED_OBJECT_CONTEXT compilationsArtist]]) {
        cell = [tableView makeViewWithIdentifier:kMainCellSubtitleCellIdentifier owner:self];
    } else {
        cell = [tableView makeViewWithIdentifier:kMainCellCompactIdentifier owner:self];
    }
    cell.toolTip = song.name;
    return cell;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[SNRSongTableRowView alloc] initWithFrame:NSZeroRect];
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    BOOL isMix = [_container isKindOfClass:[SNRMix class]] || [[_container artist] isEqual:[SONORA_MANAGED_OBJECT_CONTEXT compilationsArtist]];
    return isMix ? kTableViewSubtitleCellHeight : kTableViewCompactCellHeight;
}

// Technique from WWDC 2011 Session 120
- (void)tableViewSelectionIsChanging:(NSNotification *)notification
{
    [self adjustSelectionHighlightForVisibleCells];
    _selectionChanging = YES;
}

- (void)tableViewSelectionDidChange:(NSNotification*)notification
{
    NSIndexSet *selectedIndexes = self.tableView.selectedRowIndexes;
    NSArray *selection = nil;
    NSNumber *selected = nil;
    if ([selectedIndexes count]) {
        BOOL multipleSelection = [selectedIndexes count] > 1;
        selection = multipleSelection ? [[self.arrayController arrangedObjects] objectsAtIndexes:selectedIndexes] : [self.arrayController arrangedObjects];
        selected = multipleSelection ? nil : [NSNumber numberWithUnsignedInteger:[selectedIndexes firstIndex]];
    }
    if (!_blockMetadataNotifications) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:kEntityNameSong, SNRMetadataWindowControllerSelectionChangedEntityNameKey, selection, SNRMetadataWindowControllerSelectionChangedItemsKey, selected, SNRMetadataWindowControllerSelectionChangedSelectedKey, nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:SNRMetadataWindowControllerSelectionChangedNotification object:self userInfo:userInfo];
    }
    if (_selectionChanging) {
        _selectionChanging = NO;
    } else {
        [self adjustSelectionHighlightForVisibleCells];
    }
}

- (void)adjustSelectionHighlightForVisibleCells
{
    __block __unsafe_unretained SNRSongsViewController *bself = self;
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        SNRSongTableCellView *cellView = [rowView viewAtColumn:0];
        [bself adjustSelectionHighlightForCellView:cellView selected:rowView.selected];
    }];
}

- (void)adjustSelectionHighlightForCellView:(SNRSongTableCellView*)view selected:(BOOL)selected
{
    NSShadow *textShadow = selected ? [NSShadow shadowWithOffset:kTableViewCellTextShadowOffset blurRadius:kTableViewCellTextShadowBlurRadius color:kTableViewCellTextShadowColor] : nil;
    if (view.durationField.stringValue) {
        NSMutableParagraphStyle *durationStyle = [[NSMutableParagraphStyle alloc] init];
        [durationStyle setAlignment:NSRightTextAlignment];
        [durationStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        NSDictionary *durationAttributes = [NSDictionary dictionaryWithObjectsAndKeys:selected ? kTableViewCellTextFieldSelectedColor : kTableViewCellTextFieldLightDefaultColor, NSForegroundColorAttributeName, kTableViewCellTextFieldDefaultFont, NSFontAttributeName, durationStyle, NSParagraphStyleAttributeName, textShadow, NSShadowAttributeName, nil];
        view.durationField.attributedStringValue = [[NSAttributedString alloc] initWithString:view.durationField.stringValue attributes:durationAttributes];
    }
    if (view.trackNumberField.stringValue) {
        NSMutableParagraphStyle *trackNumberStyle = [[NSMutableParagraphStyle alloc] init];
        [trackNumberStyle setAlignment:NSCenterTextAlignment];
        [trackNumberStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        NSDictionary *trackNumberAttributes = [NSDictionary dictionaryWithObjectsAndKeys:selected ? kTableViewCellTextFieldSelectedColor : kTableViewCellTextFieldLightDefaultColor, NSForegroundColorAttributeName, kTableViewCellTextFieldDefaultFont, NSFontAttributeName, trackNumberStyle, NSParagraphStyleAttributeName, textShadow, NSShadowAttributeName, nil];
        NSNumberFormatter *formatter = (NSNumberFormatter*)[(NSCell*)view.trackNumberField.cell formatter];
        [formatter setTextAttributesForPositiveValues:trackNumberAttributes];
        view.trackNumberField.attributedStringValue = [[NSAttributedString alloc] initWithString:view.trackNumberField.stringValue attributes:trackNumberAttributes];
    }
    if (view.artistField.stringValue) {
        NSMutableParagraphStyle *artistStyle = [[NSMutableParagraphStyle alloc] init];
        [artistStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        NSDictionary *artistAttributes = [NSDictionary dictionaryWithObjectsAndKeys:selected ? kTableViewCellTextFieldSelectedColor : kTableViewCellTextFieldLightDefaultColor, NSForegroundColorAttributeName, kTableViewCellTextFieldSmallFont, NSFontAttributeName, artistStyle, NSParagraphStyleAttributeName, textShadow, NSShadowAttributeName, nil];
        view.artistField.attributedStringValue = [[NSAttributedString alloc] initWithString:view.artistField.stringValue attributes:artistAttributes];
    }
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    rowView.backgroundColor = (row % 2) ? kOddRowColor : kEvenRowColor;
    [self adjustSelectionHighlightForCellView:[rowView viewAtColumn:0] selected:rowView.selected];
}

- (id < NSPasteboardWriting >)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    return [[self.arrayController arrangedObjects] objectAtIndex:row];
}

- (void)tableView:(NSTableView*)aTableView deleteRowsAtIndexes:(NSIndexSet*)indexes
{
    [self deleteItems:[[self.arrayController arrangedObjects] objectsAtIndexes:indexes]];
}

- (void)tableViewDoubleClick:(id)sender
{
    NSInteger clickedRow = [self.tableView clickedRow];
    if (clickedRow != -1) {
        SNRSong *song = [[self.arrayController arrangedObjects] objectAtIndex:clickedRow];
        SNRQueueController *controller = SNR_MainQueueController;
        [controller clearQueueImmediately:YES];
        [controller enqueueSongs:[self.arrayController arrangedObjects]];
        [controller playFromSong:song];
        [self.popover close];
    }
}

#pragma mark -
#pragma mark NSTableViewDataSource

- (NSDragOperation)tableView:(NSTableView*)tableView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    return NSDragOperationCopy;
}

#pragma mark - NSMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    [menu removeAllItems];
    NSArray *songsArray = [[self.arrayController arrangedObjects] objectsAtIndexes:[self.tableView clickedAndSelectedRowIndexes]];
    __block __unsafe_unretained SNRSongsViewController *bself = self;
    if ([songsArray count]) {
        SNRQueueController *controller = SNR_MainQueueController;
        SNRBlockMenuItem *play = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Play", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
            [bself.popover close];
            [controller playSongs:songsArray];
        }];
        [menu addItem:play];
        SNRBlockMenuItem *enqueue = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Enqueue", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
            [controller enqueueSongs:songsArray];
        }];
        [menu addItem:enqueue];
        [menu addItem:[NSMenuItem separatorItem]];
        SNRBlockMenuItem *delete = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
            [bself.popover close];
            [bself deleteItems:songsArray];
        }];
        [menu addItem:delete];
        SNRBlockMenuItem *finder = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"ShowInFinder", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
            SNRSong *song = [songsArray objectAtIndex:0];
            [[NSWorkspace sharedWorkspace] selectFile:song.url.path inFileViewerRootedAtPath:nil];
        }];
        [menu addItem:finder];
        SNRBlockMenuItem *meta = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"EditMetadata", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
            [[SNRMetadataWindowController sharedWindowController] showWindow:nil];
        }];
        [menu addItem:meta];
    }
}

- (void)deleteItems:(NSArray*)items
{
    BOOL useOtherButton = YES;
    for (SNRSong *song in items) {
        useOtherButton = [song isDeletableFromDisk];
        if (!useOtherButton) { break; }
    }
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(useOtherButton ? @"DeleteAlertTitle" : @"DeleteAlertAlternateTitle", nil) defaultButton:NSLocalizedString(useOtherButton ? @"DeleteAlertDefaultButton" : @"DeleteAlertAlternateDefaultButton", nil) alternateButton:NSLocalizedString(@"DeleteAlertAlternateButton", nil) otherButton:useOtherButton ? NSLocalizedString(@"DeleteAlertOtherButton", nil) : nil informativeTextWithFormat:@""];
    NSInteger response = [alert runModal];
    if (response != NSAlertAlternateReturn) {
        for (SNRSong *song in items) {
            [song deleteFromLibraryAndFromDisk:(response == NSAlertOtherReturn)];
        }
        [SONORA_MANAGED_OBJECT_CONTEXT saveChanges];
    }
}

#pragma mark -
#pragma mark Button Actions

- (IBAction)editedTrackName:(id)sender
{
    NSInteger row = [self.tableView rowForView:sender];
    if (row != -1) {
        NSString *string = [sender stringValue];
        NSString *filteredName = ([string length] != 0) ? string : NSLocalizedString(@"UntitledSong", nil);
        SNRSong *song = [[self.arrayController arrangedObjects] objectAtIndex:row];
        if (![song.name isEqualToString:filteredName]) {
            song.name = filteredName;
            if (song.iTunesPersistentID) {
                [[NSUserDefaults standardUserDefaults] showFirstMetadataiTunesAlert];
            } else {
                SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:song.url];
                metadata.title = filteredName;
                [metadata writeMetadata];
            }
            [song.managedObjectContext saveChanges];
        }
    }
}

- (IBAction)editedTrackNumber:(id)sender
{
    NSInteger row = [self.tableView rowForView:sender];
    if (row != -1) {
        NSNumber *trackNumber = [NSNumber numberWithInteger:[sender integerValue]];
        SNRSong *song = [[self.arrayController arrangedObjects] objectAtIndex:row];
        if (![song.trackNumber isEqualToNumber:trackNumber]) {
            song.trackNumber = trackNumber;
            if (song.iTunesPersistentID) {
                [[NSUserDefaults standardUserDefaults] showFirstMetadataiTunesAlert];
            } else {
                SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:song.url];
                metadata.trackNumber = trackNumber;
                [metadata writeMetadata];
            }
            [song.managedObjectContext saveChanges];
        }
    }
}

- (IBAction)editedArtist:(id)sender
{
    NSInteger row = [self.tableView rowForView:sender];
    if (row != -1) {
        NSString *string = [sender stringValue];
        NSString *filteredName = ([string length] != 0) ? string : NSLocalizedString(@"UntitledArtist", nil);
        SNRSong *song = [[self.arrayController arrangedObjects] objectAtIndex:row];
        NSManagedObjectContext *context = song.managedObjectContext;
        if (![song.rawArtist isEqualToString:filteredName]) {
            song.rawArtist = filteredName;
            if (!song.rawAlbumArtist) {
                SNRArtist *artist = [context artistWithName:filteredName create:YES];
                SNRAlbum *oldAlbum = song.album;
                song.album = [context albumWithName:song.album.name byArtist:artist create:YES];
                if (![oldAlbum.songs count]) {
                    [oldAlbum deleteFromLibraryAndFromDisk:NO];
                }
            }
            if (song.iTunesPersistentID) {
                [[NSUserDefaults standardUserDefaults] showFirstMetadataiTunesAlert];
            } else {
                SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:song.url];
                metadata.artist = filteredName;
                [metadata writeMetadata];
            }
            [context saveChanges];
        }
    }
}

- (IBAction)enqueue:(id)sender
{
    NSInteger row = [self.tableView rowForView:sender];
    if (row != -1) {
        SNRSong *song = [[self.arrayController arrangedObjects] objectAtIndex:row];
        [song enqueue];
        if (!_tooltipWindow) {
            _tooltipWindow = [[SNRHUDTooltipWindow alloc] initWithTitle:NSLocalizedString(@"Enqueued", nil)];
        }
        NSPoint windowPoint = [sender convertPoint:NSMakePoint(NSMaxX([sender bounds]), NSMidY([sender bounds])) toView:nil];
        NSPoint screenPoint = [[sender window] convertRectToScreen:NSMakeRect(windowPoint.x, windowPoint.y, 0.f, 0.f)].origin;
        [_tooltipWindow flashAtPoint:screenPoint];
    }
}

- (IBAction)shuffle:(id)sender
{
    [self.popover close];
    SNRQueueController *controller = SNR_MainQueueController;
    [controller shuffleSongs:[self.arrayController arrangedObjects]];
}

- (IBAction)edit:(id)sender
{
    [self.popover close];
}
@end
