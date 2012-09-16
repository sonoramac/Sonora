//
//  SNRSearchWindowController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-03.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
