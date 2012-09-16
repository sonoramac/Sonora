//
//  SNRSearchPopoverController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-04-13.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRSearchPopoverController.h"
#import "SNRWindow.h"

#import "NSWindow+SNRAdditions.h"

#define kMaxTableViewRows 5

@interface SNRSearchPopoverController ()
- (void)windowEndedEditing:(NSNotification*)notification;
- (void)popoverDidClose:(NSNotification*)notification;
@end

@implementation SNRSearchPopoverController {
    NSPopover *_popover;
}
@synthesize searchViewController = _searchViewController;

#pragma mark - Initialization

+ (SNRSearchPopoverController*)sharedPopoverController
{
    static SNRSearchPopoverController *controller;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        controller = [[self alloc] init];
    });
    return controller;
}

- (id)init
{
    if ((self = [super init])) {
        _searchViewController = [[SNRSearchViewController alloc] initWithNibName:@"SNRSearchPopoverController" bundle:nil];
        _searchViewController.delegate = self;
        _popover = [[NSPopover alloc] init];
        _popover.contentViewController = _searchViewController;
        _popover.behavior = NSPopoverBehaviorSemitransient;
        _popover.animates = NO;
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(windowEndedEditing:) name:SNRWindowEscEndedEditingNotification object:nil];
        [nc addObserver:self selector:@selector(popoverDidClose:) name:NSPopoverDidCloseNotification object:_popover];
    }
    return self;
}

#pragma mark - Notifications

- (void)windowEndedEditing:(NSNotification*)notification
{
    [_searchViewController.searchField setStringValue:@""];
    [_popover close];
    [[notification object] endEditingPreservingFirstResponder:NO];
}

- (void)popoverDidClose:(NSNotification *)notification
{
    if ([_searchViewController.tableView numberOfRows]) {
        [_searchViewController.searchField setStringValue:@""];
    }  
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - SNRSearchViewControllerDelegate

- (void)searchViewControllerDidUpdateSearchResults:(SNRSearchViewController*)controller
{
    (void)[_searchViewController view]; // load the view
    NSTableView *tableView = _searchViewController.tableView;
    NSUInteger count = MIN(kMaxTableViewRows, [tableView numberOfRows]);
    if (count) {
        if (!_popover.shown) {
            NSTextField *searchField = _searchViewController.searchField;
            [_popover showRelativeToRect:[searchField bounds] ofView:searchField preferredEdge:NSMaxYEdge];
            NSWindow *mainWindow = [searchField window];
            [mainWindow makeFirstResponder:searchField];
            [[mainWindow fieldEditor:NO forObject:searchField] setSelectedRange:NSMakeRange([[searchField stringValue] length], 0)];
        }
        _popover.contentSize = NSMakeSize(_popover.contentSize.width, count * (tableView.rowHeight + tableView.intercellSpacing.height));
    } else {
        [_popover close];
    }
}

- (void)searchViewControllerDidClearSearchResults:(SNRSearchViewController*)controller
{
    [_popover close];
}
@end
