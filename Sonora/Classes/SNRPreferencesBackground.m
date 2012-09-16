//
//  SNRPreferencesBackground.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-04-19.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRPreferencesBackground.h"

#define kBackgroundColor [NSColor colorWithDeviceWhite:0.9f alpha:1.f]
#define kDividerColor [NSColor colorWithDeviceWhite:0.77f alpha:1.f]

@implementation SNRPreferencesBackground

- (void)drawRect:(NSRect)dirtyRect
{
    [kBackgroundColor set];
    NSRectFill([self bounds]);
    NSRect bottomDividerRect = NSMakeRect(0.f, 0.f, [self bounds].size.width, 1.f);
    NSRect topDividerRect = bottomDividerRect;
    topDividerRect.origin.y = NSMaxY([self bounds]) - 1.f;
    [kDividerColor set];
    NSRectFill(bottomDividerRect);
    NSRectFill(topDividerRect);
}

@end
