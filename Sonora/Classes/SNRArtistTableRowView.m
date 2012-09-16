//
//  SNRArtistTableRowView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-10.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtistTableRowView.h"

#define kBackgroundColor [NSColor colorWithDeviceWhite:0.95f alpha:1.f]
#define kSeparatorColor [NSColor colorWithDeviceWhite:0.90f alpha:1.f]
#define kTopHighlightColor [NSColor colorWithDeviceWhite:1.f alpha:0.6f]
#define kRightHighlightColor [NSColor colorWithDeviceWhite:1.f alpha:0.75f]

@implementation SNRArtistTableRowView
@synthesize hideSeparator = _hideSeparator;

- (BOOL)isEmphasized
{
    return YES;
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    [kBackgroundColor set];
    NSRectFill([self bounds]);
    NSRect topHighlightRect = NSMakeRect(0.f, 0.f, [self bounds].size.width, 1.f);
    [kTopHighlightColor set];
    [NSBezierPath fillRect:topHighlightRect];
    NSRect rightHighlightRect = NSMakeRect(NSMaxX([self bounds]) - 1.f, 0.f, 1.f, [self bounds].size.height);
    [kRightHighlightColor set];
    [NSBezierPath fillRect:rightHighlightRect];
    if (!self.hideSeparator) {
        NSRect separatorRect = topHighlightRect;
        separatorRect.origin.y = NSMaxY([self bounds]) - 1.f;
        [kSeparatorColor set];
        NSRectFill(separatorRect);
    }
}

- (NSTableViewSelectionHighlightStyle)selectionHighlightStyle
{
    return NSTableViewSelectionHighlightStyleSourceList;
}
@end
