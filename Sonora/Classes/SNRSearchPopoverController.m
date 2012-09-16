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
