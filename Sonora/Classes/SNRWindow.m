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

NSString* const SNRWindowEscapeKeyPressedNotification = @"SNRWindowEscapeKeyPressedNotification";
NSString* const SNRWindowSpaceKeyPressedNotification = @"SNRWindowSpaceKeyPressedNotification";
NSString* const SNRWindowLeftKeyPressedNotification = @"SNRWindowLeftKeyPressedNotification";
NSString* const SNRWindowRightKeyPressedNotification = @"SNRWindowRightKeyPressedNotification";
NSString* const SNRWindowEscEndedEditingNotification = @"SNRWindowEscEndedEditingNotification";

#import "SNRWindow.h"
#import "SNRFileImportOperation.h"
#import "SNRImportManager.h"
#import "SNRSearchPopoverController.h"
#import "SNRSearchWindowController.h"
#import "SNRSharedImageCache.h"
#import <Carbon/Carbon.h>

#import "NSBezierPath-PXRoundedRectangleAdditions.h"
#import "NSString-SNRAdditions.h"
#import "NSWindow+SNRAdditions.h"

#define kColorMainStart [NSColor colorWithDeviceWhite:0.71f alpha:1.0]
#define kColorMainEnd [NSColor colorWithDeviceWhite:0.93f alpha:1.0]
#define kColorMainBottom [NSColor colorWithDeviceRed:0.53f green:0.55f blue:0.57f alpha:1.f]
#define kColorNotMainStart [NSColor colorWithDeviceWhite:0.878 alpha:1.0]
#define kColorNotMainEnd [NSColor colorWithDeviceWhite:0.976 alpha:1.0]
#define kColorNotMainBottom [NSColor colorWithDeviceWhite:0.655 alpha:1.0]
#define kColorHighlight [NSColor colorWithDeviceWhite:1.f alpha:0.4f]
#define kCornerClipRadius 4.0

#define kTitlebarHeight 35.f
#define kFullscreenButtonRightMargin 12.f

static NSString* const kRestorationFullscreenKey = @"SNRWindowFullscreen";

@interface SNRTitlebarView : NSView
@end

@interface SNRWindow ()
- (void)commonInitForSNRWindow;
@end

@implementation SNRWindow {
    NSDragOperation _currentDragOperation;
}
@synthesize toolbarView = _toolbarView;

#pragma mark - Initialization

- (void)commonInitForSNRWindow
{
    self.titleBarView = [[SNRTitlebarView alloc] initWithFrame:NSZeroRect];
    self.titleBarHeight = kTitlebarHeight;
    self.centerFullScreenButton = YES;
    self.centerTrafficLightButtons = YES;
    self.fullScreenButtonRightMargin = kFullscreenButtonRightMargin;
    self.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(windowDidBecomeKey:) name:NSWindowDidBecomeKeyNotification object:self];
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInitForSNRWindow];
    }
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])) {
        [self commonInitForSNRWindow];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.titleBarView addSubview:self.toolbarView];
}


- (void)windowDidBecomeKey:(NSNotification*)notification
{
    SNRSearchWindowController *searchWindowController = [SNRSearchWindowController sharedWindowController];
    searchWindowController.openedViaShortcut = NO;
    if (searchWindowController.window.isVisible) {
        [searchWindowController hideWindow:nil];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeBool:[self isFullscreen] forKey:kRestorationFullscreenKey];
}

- (void)restoreStateWithCoder:(NSCoder *)coder
{
    [super restoreStateWithCoder:coder];
    BOOL fullscreen = [coder decodeBoolForKey:kRestorationFullscreenKey];
    if (fullscreen) {
        [self toggleFullScreen:nil];
    }
}

#pragma mark - Drag and Drop Importing

- (NSDragOperation)draggingEntered:(id < NSDraggingInfo >)sender
{
    if ([sender draggingSource]) { return NSDragOperationNone; } // this means that the drag started in Sonora
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    BOOL valid = [SNRFileImportOperation validateFiles:files];
    _currentDragOperation = valid ? NSDragOperationCopy : NSDragOperationNone;
    return _currentDragOperation;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
    [[SNRImportManager sharedImportManager] importFiles:files play:NO];
    return YES;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
    return _currentDragOperation;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
    _currentDragOperation = NSDragOperationNone;
}

#pragma mark - Event Handling

- (void)sendEvent:(NSEvent *)theEvent
{
    NSResponder *responder = self.firstResponder;
    BOOL responderText = [responder isKindOfClass:[NSText class]];
    BOOL responderNotEditing = !responderText || (responderText && ![(NSText*)responder string].length);
    switch (theEvent.type) {
        case NSKeyDown: {
            NSUInteger flags = [theEvent modifierFlags];
            NSUInteger maskedFlags = flags & NSDeviceIndependentModifierFlagsMask;
            if (maskedFlags && ((flags & NSNumericPadKeyMask) != NSNumericPadKeyMask)) {
                [super sendEvent:theEvent];
                return;
            }
            unsigned short keyCode = [theEvent keyCode];
            NSString *notification = nil;
            switch (keyCode) {
                case kVK_Escape:
                    if (responderText) {
                        notification = SNRWindowEscEndedEditingNotification;
                    } else {
                        notification = SNRWindowEscapeKeyPressedNotification;
                    }
                    break;
                case kVK_Space:
                    if (responderNotEditing) {
                        notification = SNRWindowSpaceKeyPressedNotification;
                    }
                    break;
                case kVK_LeftArrow:
                    if (responderNotEditing) {
                        notification = SNRWindowLeftKeyPressedNotification;
                    }
                    break;
                case kVK_RightArrow:
                    if (responderNotEditing) {
                        notification = SNRWindowRightKeyPressedNotification;
                    }
                    break;
                default:
                    break;
            }
            if (notification) {
                [[NSNotificationCenter defaultCenter] postNotificationName:notification object:self];
                return;
            }
            if ([[[theEvent characters] stringByFilteringToCharactersInSet:[NSCharacterSet alphanumericCharacterSet]] length] && !responderText) {
                NSTextField *searchField = [SNRSearchPopoverController sharedPopoverController].searchViewController.searchField;
                NSWindow *window = [searchField window];
                [window makeFirstResponder:searchField];
                [super sendEvent:theEvent];
            } else {
                [super sendEvent:theEvent];
            }
            break;
        } default:
            [super sendEvent:theEvent];
            break;
    }
}


@end

@implementation SNRTitlebarView
- (void)drawRect:(NSRect)dirtyRect
{
    BOOL drawsAsMainWindow = [self.window drawAsActive];
    NSRect drawingRect = [self bounds];
    drawingRect.size.height -= 1.0; // Decrease the height by 1.0px to show the highlight line at the top
    NSColor *startColor = drawsAsMainWindow ? kColorMainStart : kColorNotMainStart;
    NSColor *endColor = drawsAsMainWindow ? kColorMainEnd : kColorNotMainEnd;
    [NSGraphicsContext saveGraphicsState];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:drawingRect cornerRadius:kCornerClipRadius inCorners:OSTopLeftCorner | OSTopRightCorner];
    [path addClip];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startColor endingColor:endColor];
    [gradient drawInRect:drawingRect angle:90];
    if (drawsAsMainWindow) {
        [[SNRSharedImageCache sharedInstance] drawNoiseImage];
    }
    NSColor *bottomColor = drawsAsMainWindow ? kColorMainBottom : kColorNotMainBottom;
    NSRect bottomRect = NSMakeRect(0.0, NSMinY(drawingRect), NSWidth(drawingRect), 1.0);
    [bottomColor set];
    NSRectFill(bottomRect);
    NSRect highlightRect = NSMakeRect(0.f, NSMaxY(self.bounds) - 1.f, self.bounds.size.width, 1.f);
    [kColorHighlight set];
    [NSBezierPath fillRect:highlightRect];
    [NSGraphicsContext restoreGraphicsState];
}
@end