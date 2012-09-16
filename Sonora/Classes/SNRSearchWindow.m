//
//  SNRSearchWindow.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-03.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRSearchWindow.h"
#import "SNRSearchWindowController.h"
#import <Carbon/Carbon.h>

#define kNoModifierFlagsMask 256
#define kLayoutResultsInset 5.f
#define kBackgroundOpacity 0.95f
#define kBackgroundCornerRadius 4.f

static NSString* const kImageSearchBox = @"search-box";

@implementation SNRSearchWindow
@synthesize drawBackground = _drawBackground;

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)windowStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)deferCreation
{
    if (self = [super
                initWithContentRect:contentRect
                styleMask:NSBorderlessWindowMask
                backing:bufferingType
                defer:deferCreation]) {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setMovableByWindowBackground:YES];
        [self setMovable:YES];
        
    }
    return self;
}

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)sendEvent:(NSEvent *)theEvent
{
    // Detect Command + W to close window
    if ([theEvent type] == NSKeyDown) {
        NSUInteger modifierFlags = [theEvent modifierFlags];
        unsigned short keyCode = [theEvent keyCode];
        BOOL commandW = (modifierFlags & NSCommandKeyMask) == NSCommandKeyMask && keyCode == kVK_ANSI_W;
        BOOL escape = !(modifierFlags & NSDeviceIndependentModifierFlagsMask) && keyCode == kVK_Escape;
        if (commandW || escape) {
            [self.windowController hideWindow:nil];
            return;
        }
    }
    [super sendEvent:theEvent];
}
@end

@implementation SNRSearchWindowContentView

- (void)drawRect:(NSRect)dirtyRect
{
    if ([(SNRSearchWindow*)[self window] drawBackground]) {
        [[NSColor colorWithDeviceWhite:1.f alpha:kBackgroundOpacity] set];
        NSRect resultsRect = NSMakeRect(kLayoutResultsInset, 0.f, self.bounds.size.width - (kLayoutResultsInset * 2.f), self.bounds.size.height - kLayoutResultsInset);
        NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:resultsRect xRadius:kBackgroundCornerRadius yRadius:kBackgroundCornerRadius];
        [path fill];
    }
    NSImage *box = [NSImage imageNamed:kImageSearchBox];
    NSSize size = box.size;
    NSRect boxRect = NSMakeRect(0.f, NSMaxY(self.bounds) - size.height, size.width, size.height);
    [box drawInRect:boxRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.f];
}
@end