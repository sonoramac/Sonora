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

#import "SNRQueueScrollView.h"
#import "SNRQueueScroller.h"
#import "SNRSharedImageCache.h"

#import "NSWindow+SNRAdditions.h"

#define kQueueViewGradientStartingColor [NSColor colorWithDeviceWhite:0.84f alpha:1.f]
#define kQueueViewGradientEndingColor [NSColor colorWithDeviceWhite:0.76f alpha:1.f]
#define kQueueViewInactiveGradientStartingColor [NSColor colorWithDeviceWhite:0.92 alpha:1.f]
#define kQueueViewInactiveGradientEndingColor [NSColor colorWithDeviceWhite:0.88 alpha:1.f]
#define kQueueViewShadowStartingColor [NSColor colorWithDeviceWhite:0.f alpha:0.4f]
#define kQueueViewShadowEndingColor [NSColor clearColor]
#define kQueueViewShadowLength 3.f

@interface SNRQueueClipView : NSClipView
@end

@implementation SNRQueueClipView
- (void)drawRect:(NSRect)dirtyRect
{
    BOOL drawAsActive = [[self window] drawAsActive];
    NSRect fillRect = NSMakeRect(dirtyRect.origin.x, 0.f, dirtyRect.size.width, [self bounds].size.height);
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:drawAsActive? kQueueViewGradientStartingColor : kQueueViewInactiveGradientStartingColor endingColor:drawAsActive ? kQueueViewGradientEndingColor : kQueueViewInactiveGradientEndingColor];
    [gradient drawInRect:fillRect angle:270];
    [[SNRSharedImageCache sharedInstance] drawNoiseImage];
    NSGradient *shadow = [[NSGradient alloc] initWithStartingColor:kQueueViewShadowStartingColor endingColor:kQueueViewShadowEndingColor];
    NSRect shadowRect = fillRect;
    shadowRect.size.height = kQueueViewShadowLength;
    [shadow drawInRect:shadowRect angle:90];
}
@end

@implementation SNRQueueScrollView {
    SNRQueueClipView *_clipView;
}
@synthesize blockScrollEvents = _blockScrollEvents;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        id docView = [self documentView];
        _clipView = [[SNRQueueClipView alloc] initWithFrame:
                     [[self contentView] frame]];
        [self setContentView:_clipView];
        [self setDocumentView:docView];
    }
    return self;
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    if (!self.blockScrollEvents) {
        [super scrollWheel:theEvent];
    }
}

@end
