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

#import "SNRSearchWindowController.h"
#import "SNRSearchWindow.h"
#import "SNRSearchViewController.h"

#import "NSWindow+SNRAdditions.h"

#define kMaxTableViewRows 5
#define kWindowBaseHeight 64.f

@implementation SNRSearchWindowController
@synthesize openedViaShortcut = _openedViaShortcut;
@synthesize searchViewController = _searchViewController;

- (id)initWithWindowNibName:(NSString *)windowNibName
{
    if ((self = [super initWithWindowNibName:windowNibName])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideWindow:) name:NSWindowDidResignKeyNotification object:self.window];
    }
    return self;
}

+ (SNRSearchWindowController*)sharedWindowController;
{
    static SNRSearchWindowController *controller;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        controller = [[self alloc] initWithWindowNibName:NSStringFromClass([self class])];
    });
    return controller;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)showWindow:(id)sender
{
    [self.window fadeIn:nil];
}

- (IBAction)hideWindow:(id)sender
{
    [self.window fadeOut:nil];
    if (self.openedViaShortcut) {
        self.openedViaShortcut = NO;
        [NSApp hide:nil];
    }
}

- (IBAction)toggleVisible:(id)sender
{
    self.window.isVisible ? [self hideWindow:nil] : [self showWindow:nil];
}

#pragma mark - SNRSearchViewControllerDelegate

- (void)searchViewControllerDidUpdateSearchResults:(SNRSearchViewController*)controller
{
    NSTableView *tableView = _searchViewController.tableView;
    NSUInteger count = MIN(kMaxTableViewRows, [tableView numberOfRows]);
    SNRSearchWindow *window = (SNRSearchWindow*)self.window;
    NSRect newWindowFrame = window.frame;
    CGFloat newWindowHeight = 0.0;
    if (!count) {
        window.drawBackground = NO;
        newWindowHeight = kWindowBaseHeight;
    } else {
        window.drawBackground = YES;
        newWindowHeight = kWindowBaseHeight + (count * (tableView.rowHeight + tableView.intercellSpacing.height));
    }
    CGFloat change = newWindowHeight - newWindowFrame.size.height;
    newWindowFrame.size.height += change;
    newWindowFrame.origin.y -= change;
    [window setFrame:newWindowFrame display:YES animate:NO];
}

- (void)searchViewControllerDidClearSearchResults:(SNRSearchViewController*)controller
{
    [self hideWindow:nil];
}
@end
