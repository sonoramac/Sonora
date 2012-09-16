//
//  SNRQueueSidebar.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-31.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
