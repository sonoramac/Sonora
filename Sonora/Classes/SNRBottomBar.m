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

#import "SNRBottomBar.h"
#import "SNRSharedImageCache.h"

#import "NSBezierPath-PXRoundedRectangleAdditions.h"
#import "NSWindow+SNRAdditions.h"

#define kBackgroundGradientStartingColor [NSColor colorWithDeviceWhite:0.53f alpha:1.f]
#define kBackgroundGradientEndingColor [NSColor colorWithDeviceWhite:0.78f alpha:1.f]
#define kBackgroundGradientDeactiveStartingColor [NSColor colorWithDeviceWhite:0.878 alpha:1.0]
#define kBackgroundGradientDeactiveEndingColor [NSColor colorWithDeviceWhite:0.976 alpha:1.0]
#define kBackgroundCornerClippingRadius 4.f
#define kBackgroundHighlightColor [NSColor colorWithDeviceWhite:1.f alpha:0.3f]

@implementation SNRBottomBar

- (void)drawRect:(NSRect)dirtyRect
{
    BOOL drawsAsMainWindow = [self.window drawAsActive];
    NSColor *startingColor = drawsAsMainWindow ? kBackgroundGradientStartingColor : kBackgroundGradientDeactiveStartingColor;
    NSColor *endingColor = drawsAsMainWindow ? kBackgroundGradientEndingColor : kBackgroundGradientDeactiveEndingColor;
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:startingColor endingColor:endingColor];
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:kBackgroundCornerClippingRadius inCorners:OSBottomLeftCorner | OSBottomRightCorner];
    [gradient drawInBezierPath:path angle:90];
    [[SNRSharedImageCache sharedInstance] drawNoiseImage];
    [path addClip];
    NSRect highlightRect = NSMakeRect(0.f, NSMaxY(self.bounds) - 1.f, self.bounds.size.width, 1.f);
    [kBackgroundHighlightColor set];
    [NSBezierPath fillRect:highlightRect];
}

@end
