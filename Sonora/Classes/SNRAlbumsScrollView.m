//
//  SNRAlbumsScrollView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-04.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRAlbumsScrollView.h"

#import "NSWindow+SNRAdditions.h"

static NSString* const kImageBackground = @"crosshatch-bg";
static NSString* const kImageBackgroundDisabled = @"crosshatch-bg-inactive";

#define kGridViewLeftGradientStartingColor [NSColor colorWithDeviceWhite:0.f alpha:0.1f]
#define kGridViewLeftGradientEndingColor [NSColor clearColor]
#define kGridViewLeftGradientLength 3.f

@interface SNRAlbumsClipView : NSClipView
@end

@implementation SNRAlbumsClipView

- (void)drawRect:(NSRect)dirtyRect
{
    NSImage *bg = [NSImage imageNamed:[self.window drawAsActive] ? kImageBackground : kImageBackgroundDisabled];
    NSColor *color = [NSColor colorWithPatternImage:bg];
    [color set];
    NSRectFill(dirtyRect);
    [[NSColor redColor] set];
    NSRect fillRect = NSMakeRect(0.f, dirtyRect.origin.y, kGridViewLeftGradientLength, dirtyRect.size.height);
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:kGridViewLeftGradientStartingColor endingColor:kGridViewLeftGradientEndingColor];
    [gradient drawInRect:fillRect angle:0];
}

@end

@implementation SNRAlbumsScrollView {
    SNRAlbumsClipView *_clipView;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        id docView = [self documentView];
        _clipView = [[SNRAlbumsClipView alloc] initWithFrame:
                     [[self contentView] frame]];
        [self setContentView:_clipView];
        [self setDocumentView:docView];
        [[self horizontalScroller] setControlSize:NSSmallControlSize];
    }
    return self;
}
@end
