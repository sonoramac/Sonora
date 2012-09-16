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

#import "SNRSearchViewController.h"
#import "SNRSearchTableCellView.h"
#import "SNRSearchController.h"
#import "SNRBlockMenuItem.h"
#import "SNRSong.h"
#import "SNRAlbum.h"
#import "SNRArtist.h"
#import "SNRArtistsStaticNode.h"

#import "NSTableView-SNRAdditions.h"
#import "NSShadow-SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"

static NSString* const kTitleCellIdentifier = @"TitleCell";
static NSString* const kSubtitleCellIdentifier = @"SubtitleCell";

#define kTableViewCellTextFieldDefaultColor [NSColor colorWithDeviceWhite:0.408f alpha:1.f]
#define kTableViewCellTextFieldDefaultFont [NSFont systemFontOfSize:13.f]
#define kTableViewCellTextFieldSmallFont [NSFont systemFontOfSize:11.f]
#define kTableViewCellTextFieldSelectedColor [NSColor whiteColor]
#define kTableViewCellTextShadowColor [NSColor colorWithDeviceWhite:0.f alpha:0.5f]
#define kTableViewCellTextShadowOffset NSMakeSize(0.f, -1.f)
#define kTableViewCellTextShadowBlurRadius 2.f

#define kEvenRowColor [NSColor colorWithDeviceWhite:0.95f alpha:1.f]
#define kOddRowColor [NSColor colorWithDeviceWhite:0.93f alpha:1.f]

@interface SNRSearchViewController ()
- (void)clearSearchResults;
- (void)adjustSelectionHighlightForCellView:(SNRSearchTableCellView*)view selected:(BOOL)selected;
@end

@implementation SNRSearchViewController {
    BOOL _awakenFromNib;
}
@synthesize searchController = _searchController;
@synthesize delegate = _delegate;
@synthesize tableView = _tableView;
@synthesize searchField = _searchField;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        _searchController = [SNRSearchController new];
        [_searchController addObserver:self forKeyPath:@"searchResults" options:0 context:NULL];
    }
    return self;
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    if (_awakenFromNib) { return; }
    if (!_searchController) {
        _searchController = [SNRSearchController new];
        [_searchController addObserver:self forKeyPath:@"searchResults" options:0 context:NULL];
    }
    self.tableView.target = self;
    self.tableView.doubleAction = @selector(tableViewDoubleClick:);
    _awakenFromNib = YES;
}

- (void)dealloc
{
    [_searchController removeObserver:self forKeyPath:@"searchResults"];
}

#pragma mark - Key Value Observation

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.tableView reloadData];
    if ([self.delegate respondsToSelector:@selector(searchViewControllerDidUpdateSearchResults:)]) {
        [self.delegate searchViewControllerDidUpdateSearchResults:self];
    }
}

#pragma mark - NSTableViewDataSource

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView
{
    return [_searchController.searchResults count];
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex
{
    return [_searchController.searchResults objectAtIndex:rowIndex];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    id anObject = [_searchController.searchResults objectAtIndex:row];
    SNRSearchTableCellView *cellView = nil;
    if ([anObject isKindOfClass:[SNRSong class]] || [anObject isKindOfClass:[SNRAlbum class]]) {
        cellView = [tableView makeViewWithIdentifier:kSubtitleCellIdentifier owner:self];
        [cellView.enqueueButton setHidden:NO];
    } else {
        cellView = [tableView makeViewWithIdentifier:kTitleCellIdentifier owner:self];
        [cellView.enqueueButton setHidden:[anObject isKindOfClass:[SNRArtistsStaticNode class]]];
    }
    return cellView;
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row
{
    return [[SNRSearchTableRowView alloc] initWithFrame:NSZeroRect];
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NSTableRowView *)rowView forRow:(NSInteger)row
{
    rowView.backgroundColor = (row % 2) ? kOddRowColor : kEvenRowColor;
    [self adjustSelectionHighlightForCellView:[rowView viewAtColumn:0] selected:rowView.selected];
}

- (id < NSPasteboardWriting >)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row
{
    return [_searchController.searchResults objectAtIndex:row];
}

- (void)tableViewSelectionDidChange:(NSNotification*)notification
{
    __block __unsafe_unretained SNRSearchViewController *bself = self;
    [self.tableView enumerateAvailableRowViewsUsingBlock:^(NSTableRowView *rowView, NSInteger row) {
        SNRSearchTableCellView *cellView = [rowView viewAtColumn:0];
        [bself adjustSelectionHighlightForCellView:cellView selected:rowView.selected];
    }];
}

- (void)adjustSelectionHighlightForCellView:(SNRSearchTableCellView*)view selected:(BOOL)selected
{
    NSShadow *textShadow = selected ? [NSShadow shadowWithOffset:kTableViewCellTextShadowOffset blurRadius:kTableViewCellTextShadowBlurRadius color:kTableViewCellTextShadowColor] : nil;
    if (view.statisticTextField.stringValue) {
        NSMutableParagraphStyle *statisticStyle = [[NSMutableParagraphStyle alloc] init];
        [statisticStyle setAlignment:NSRightTextAlignment];
        [statisticStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        NSDictionary *statisticAttributes = [NSDictionary dictionaryWithObjectsAndKeys:selected ? kTableViewCellTextFieldSelectedColor : kTableViewCellTextFieldDefaultColor, NSForegroundColorAttributeName, kTableViewCellTextFieldDefaultFont, NSFontAttributeName, statisticStyle, NSParagraphStyleAttributeName, textShadow, NSShadowAttributeName, nil];
        view.statisticTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:view.statisticTextField.stringValue attributes:statisticAttributes];
    }
    if (view.subtitleTextField.stringValue) {
        NSMutableParagraphStyle *defaultStyle = [[NSMutableParagraphStyle alloc] init];
        [defaultStyle setLineBreakMode:NSLineBreakByTruncatingTail];
        NSDictionary *subtitleAttributes = [NSDictionary dictionaryWithObjectsAndKeys:selected ? kTableViewCellTextFieldSelectedColor : kTableViewCellTextFieldDefaultColor, NSForegroundColorAttributeName, kTableViewCellTextFieldSmallFont, NSFontAttributeName, defaultStyle, NSParagraphStyleAttributeName, textShadow, NSShadowAttributeName, nil];
        view.subtitleTextField.attributedStringValue = [[NSAttributedString alloc] initWithString:view.subtitleTextField.stringValue attributes:subtitleAttributes];
    }
}

#pragma mark - Table View Actions

- (IBAction)enqueueItem:(id)sender
{
    NSInteger row = [self.tableView rowForView:sender];
    if (row != -1) {
        [_searchController enqueueObject:[_searchController.searchResults objectAtIndex:row]];
        [self clearSearchResults];
    }
}

- (void)tableViewDoubleClick:(id)sender
{
    NSInteger clickedRow = [self.tableView clickedRow];
    if (clickedRow != -1) {
        id object = [_searchController.searchResults objectAtIndex:clickedRow];
        [_searchController openSearchResultWithObject:object];
        [self clearSearchResults];
    }
}

#pragma mark - NSTextFieldDelegate

- (void)controlTextDidBeginEditing:(NSNotification *)obj
{
    if ([self.delegate respondsToSelector:@selector(searchViewControllerDidBeginEditingSearchField:)]) {
        [self.delegate searchViewControllerDidBeginEditingSearchField:self];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    if ([self.delegate respondsToSelector:@selector(searchViewControllerDidEndEditingSearchField:)]) {
        [self.delegate searchViewControllerDidEndEditingSearchField:self];
    }
}

- (void)controlTextDidChange:(NSNotification *)aNotification
{
    [_searchController performSearchForQuery:self.searchField.stringValue handler:nil];
}

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)command
{
    NSInteger selectedRow = [self.tableView selectedRow];
    NSInteger rowToSelect = -1;
    if (command == @selector(moveUp:)) {
        rowToSelect = selectedRow - 1;
    } else if (command == @selector(moveDown:)) {
        rowToSelect = selectedRow + 1;
    } else if (((command == @selector(insertNewline:)) || (command == @selector(insertNewlineIgnoringFieldEditor:)) || (command == @selector(noop:))) && [_searchController.searchResults count]) {
        if (selectedRow == -1) { selectedRow = 0; }
        id selectedObject = [_searchController.searchResults  objectAtIndex:selectedRow];
        [_searchController openSearchResultWithObject:selectedObject];
        [self clearSearchResults];
    } else {
        return NO;
    }
    if (rowToSelect >= 0 && rowToSelect <= ([self.tableView numberOfRows] - 1)) {
        [self.tableView selectRowIndexes:[NSIndexSet indexSetWithIndex:rowToSelect] byExtendingSelection:NO];
        [self.tableView scrollRowToVisibleAnimated:rowToSelect];
    }
    return YES;
}

- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index
{
    [self clearSearchResults];
    return nil;
}

#pragma mark - NSMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    [menu removeAllItems];
    NSUInteger index = [[self.tableView clickedAndSelectedRowIndexes] firstIndex];
    id object = [_searchController.searchResults objectAtIndex:index];
    __block __unsafe_unretained SNRSearchViewController *bself = self;
    SNRBlockMenuItem *play = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString([object isKindOfClass:[SNRArtist class]] ? @"Shuffle" : @"Play", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        [bself->_searchController playObject:object];
    }];
    [menu addItem:play];
    SNRBlockMenuItem *enqueue = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Enqueue", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
        [bself->_searchController enqueueObject:object];
    }];
    [menu addItem:enqueue];
    if ([object isKindOfClass:[NSManagedObject class]]) {
        SNRBlockMenuItem *delete = [[SNRBlockMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", nil) keyEquivalent:@"" block:^(NSMenuItem *item) {
            BOOL deletable = [object isDeletableFromDisk];
            NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(deletable ? @"DeleteAlertTitle" : @"DeleteAlertAlternateTitle", nil) defaultButton:NSLocalizedString(deletable ? @"DeleteAlertDefaultButton" : @"DeleteAlertAlternateDefaultButton", nil) alternateButton:NSLocalizedString(@"DeleteAlertAlternateButton", nil) otherButton:deletable ? NSLocalizedString(@"DeleteAlertOtherButton", nil) : nil informativeTextWithFormat:@""];
            NSInteger response = [alert runModal];
            if (response != NSAlertAlternateReturn) {
                [(id)object deleteFromLibraryAndFromDisk:(response == NSAlertOtherReturn)];
                [SONORA_MANAGED_OBJECT_CONTEXT saveChanges];
            }
        }];
        [menu addItem:delete];
    }
}

#pragma mark - Private

- (void)clearSearchResults
{
    self.searchField.stringValue = @"";
    [self.tableView scrollToBeginningOfDocument:nil];
    if ([self.delegate respondsToSelector:@selector(searchViewControllerDidClearSearchResults:)]) {
        [self.delegate searchViewControllerDidClearSearchResults:self];
    }
}
@end
