//
//  SNRArtistsOutlineView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtistsOutlineView.h"

#define kHighlightColor [NSColor colorWithDeviceWhite:1.f alpha:0.75f]

@implementation SNRArtistsOutlineView
- (void)drawBackgroundInClipRect:(NSRect)clipRect
{
    [super drawBackgroundInClipRect:clipRect];
    NSRect highlightRect = clipRect;
    highlightRect.size.width = 1.f;
    highlightRect.origin.x = NSMaxX([self bounds]) - 1.f;
    [kHighlightColor set];
    [NSBezierPath fillRect:highlightRect];
}
@end
