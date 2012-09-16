//
//  SNRArtistHeaderTableRowView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-12.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtistHeaderTableRowView.h"

#define kBackgroundGradientStartingColor [NSColor colorWithDeviceWhite:0.87f alpha:1.f]
#define kBackgroundGradientEndingColor [NSColor colorWithDeviceWhite:0.96f alpha:1.f]
#define kBackgroundHighlightColor [NSColor colorWithDeviceWhite:1.f alpha:0.7f]
#define kBackgroundSeparatorColor [NSColor colorWithDeviceWhite:0.72f alpha:1.f]

@implementation SNRArtistHeaderTableRowView

- (BOOL)isEmphasized
{
    return NO;
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    [super drawBackgroundInRect:dirtyRect];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:kBackgroundGradientStartingColor endingColor:kBackgroundGradientEndingColor];
    [gradient drawInRect:[self bounds] angle:270];
    NSRect topSeparatorRect = NSMakeRect(0.f, 0.f, [self bounds].size.width, 1.f);
    NSRect bottomSeparatorRect = topSeparatorRect;
    bottomSeparatorRect.origin.y = NSMaxY([self bounds]) - 1.f;
    NSRect highlightRect = topSeparatorRect;
    highlightRect.origin.y += 1.f;
    [kBackgroundSeparatorColor set];
    NSRectFill(topSeparatorRect);
    NSRectFill(bottomSeparatorRect);
    [kBackgroundHighlightColor set];
    [NSBezierPath fillRect:highlightRect];
}
@end
