//
//  SNRSongTableCellView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-04.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRSongTableCellView.h"

#define kSeparatorColor [NSColor colorWithDeviceWhite:0.90f alpha:1.f]
#define kLayoutPlusButtonWidth 35.f

static NSString* const kImagePlus = @"<SNRSongsViewController>plus";
static NSString* const kImageShuffle = @"shuffle";

@implementation SNRSongTableCellView
@synthesize trackNumberField = _trackNumberField;
@synthesize artistField = _artistField;
@synthesize durationField = _durationField;
@synthesize enqueueButton = _enqueueButton;
@end

@implementation SNRSongTableRowView

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    [super drawBackgroundInRect:dirtyRect];
    NSRect separatorRect = NSMakeRect(0.f, NSMaxY([self bounds]) - 1.f, [self bounds].size.width, 1.f);
    [kSeparatorColor set];
    NSRectFill(separatorRect);
    NSRect plusSeparator = NSMakeRect(NSMaxX([self bounds]) - kLayoutPlusButtonWidth, 0.f, 1.f, [self bounds].size.height);
    NSRectFill(plusSeparator);
}

@end