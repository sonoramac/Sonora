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

#import "SNRQueueSidebar.h"
#import "SNRSharedImageCache.h"

#define kBackgroundVerticalStartingColor [NSColor colorWithDeviceWhite:0.72f alpha:1.f]
#define kBackgroundVerticalEndingColor [NSColor colorWithDeviceWhite:0.84f alpha:1.f]
#define kBackgroundHorizontalStartingColor [NSColor colorWithDeviceWhite:0.f alpha:0.08f]
#define kBackgroundHorizontalEndingColor [NSColor colorWithDeviceWhite:1.f alpha:0.08f]
#define kHighlightColor [NSColor colorWithDeviceWhite:1.f alpha:0.25f]
#define kBorderColor [NSColor colorWithDeviceRed:0.51f green:0.52f blue:0.53f alpha:1.f]

@implementation SNRQueueSidebar

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect borderRect = NSMakeRect(0.f, NSMaxY([self bounds]) - 1.f, [self bounds].size.width, 1.f);
    [kBorderColor set];
    NSRectFill(borderRect);
    NSRect gradientRect = NSMakeRect(0.f, 0.f, [self bounds].size.width, [self bounds].size.height - 1.f);
    NSGradient *vertical = [[NSGradient alloc] initWithStartingColor:kBackgroundVerticalStartingColor endingColor:kBackgroundVerticalEndingColor];
    [vertical drawInRect:gradientRect angle:90];
    NSGradient *horizontal = [[NSGradient alloc] initWithStartingColor:kBackgroundHorizontalStartingColor endingColor:kBackgroundHorizontalEndingColor];
    [horizontal drawInRect:gradientRect angle:180];
    NSRect leftHighlight = gradientRect;
    leftHighlight.size.width = 1.f;
    [kHighlightColor set];
    [NSBezierPath fillRect:leftHighlight];
    NSRect topHighlight = borderRect;
    topHighlight.origin.y -= 1.f;
    [NSBezierPath fillRect:topHighlight];
    [[SNRSharedImageCache sharedInstance] drawNoiseImage];
}

@end
