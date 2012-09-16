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