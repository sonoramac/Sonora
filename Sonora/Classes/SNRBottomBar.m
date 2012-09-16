//
//  SNRBottomBar.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
