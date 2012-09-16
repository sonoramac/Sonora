//
//  SNRUIController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-01.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRUIController.h"
#import "SNRWindow.h"
#import "SNRAlbumsViewController.h"

#import "NSWindow+SNRAdditions.h"

static NSString* const kUserDefaultsLastDividerPositionKey = @"lastDividerPosition";

#define kArtistsViewMinDimension 180.f
#define kAlbumsViewMinDimension 250.f
#define kViewMenuShowHideArtistsListIndex 2
#define kLayoutButtonEdgeMargin 15.f
#define kLayoutButtonSpacing 17.f
#define kTitlebarXOriginWindow 90.0
#define kTitlebarXOriginFullscreen 15.0

@interface SNRUIController ()
- (void)layoutToolbarViewForFullscreen:(BOOL)fullscreen;
@end

@implementation SNRUIController
@synthesize splitView = _splitView;
@synthesize mainWindow = _mainWindow;
@synthesize artistsView = _artistsView;

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(windowWillEnterFullScreen:) name:NSWindowWillEnterFullScreenNotification object:self.mainWindow];
    [nc addObserver:self selector:@selector(windowWillExitFullScreen:) name:NSWindowWillExitFullScreenNotification object:self.mainWindow];
    [self layoutToolbarViewForFullscreen:[self.mainWindow isFullscreen]];
    [[NSUserDefaults standardUserDefaults] setFloat:NSMaxX([self.artistsView frame]) forKey:kUserDefaultsLastDividerPositionKey];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Window

- (void)layoutToolbarViewForFullscreen:(BOOL)fullscreen
{
    static CGFloat fullscreenButtonWidth = 0.0;
    if (!fullscreenButtonWidth) {
        fullscreenButtonWidth = [[self.mainWindow standardWindowButton:NSWindowFullScreenButton] frame].size.width;
    }
    SNRWindow *window = self.mainWindow;
    NSRect newFrame = window.toolbarView.frame;
    newFrame.size.height = window.titleBarHeight;
    NSView *artists = [[self.splitView subviews] objectAtIndex:0];
    CGFloat xOrigin = MAX(fullscreen ? kTitlebarXOriginFullscreen : kTitlebarXOriginWindow, [artists isHidden] ? 0.f : NSMaxX([artists frame]));
    newFrame.origin.x = xOrigin;
    newFrame.size.width = window.titleBarView.bounds.size.width - (fullscreen ? (xOrigin + window.fullScreenButtonRightMargin) : (xOrigin + fullscreenButtonWidth + window.fullScreenButtonRightMargin*2.f));
    self.mainWindow.toolbarView.frame = newFrame;
}

#pragma mark - Notifications

- (void)windowWillEnterFullScreen:(NSNotification*)notification
{
    [self layoutToolbarViewForFullscreen:YES];
}

- (void)windowWillExitFullScreen:(NSNotification*)notification
{
    [self layoutToolbarViewForFullscreen:NO];
}

#pragma mark - NSSplitViewDelegate

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
    if (subview == self.artistsView && [[splitView window] inLiveResize]) {
        return NO;
    }
    return YES;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)aNotification
{
    [self layoutToolbarViewForFullscreen:[self.mainWindow isFullscreen]];
    if (![self.artistsView isHidden]) {
        [[NSUserDefaults standardUserDefaults] setFloat:NSMaxX([self.artistsView frame]) forKey:kUserDefaultsLastDividerPositionKey];
    }
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {
    return proposedMin + kArtistsViewMinDimension;
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    return subview == self.artistsView;
}

#pragma mark - NSMenuDelegate

- (void)menuNeedsUpdate:(NSMenu *)menu
{
    NSArray *items = [menu itemArray];
    NSMenuItem *hide = [items objectAtIndex:kViewMenuShowHideArtistsListIndex];
    hide.title = NSLocalizedString([self.artistsView isHidden] ? @"ShowArtistsList" : @"HideArtistsList", nil);
    hide.target = self;
    hide.action = @selector(showHideArtistsView:);
}

- (IBAction)showHideArtistsView:(id)sender
{
    if (![self.artistsView isHidden]) {
        [self.splitView setPosition:0.f ofDividerAtIndex:0];
    } else {
        [self.splitView setPosition:[[NSUserDefaults standardUserDefaults] floatForKey:kUserDefaultsLastDividerPositionKey] ofDividerAtIndex:0];
    }
}
@end
