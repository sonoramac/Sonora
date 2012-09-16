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
