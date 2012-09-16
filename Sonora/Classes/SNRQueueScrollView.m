//
//  SNRQueueScrollView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-22.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRQueueScrollView.h"
#import "SNRQueueScroller.h"
#import "SNRSharedImageCache.h"

#import "NSWindow+SNRAdditions.h"

#define kQueueViewGradientStartingColor [NSColor colorWithDeviceWhite:0.84f alpha:1.f]
#define kQueueViewGradientEndingColor [NSColor colorWithDeviceWhite:0.76f alpha:1.f]
#define kQueueViewInactiveGradientStartingColor [NSColor colorWithDeviceWhite:0.92 alpha:1.f]
#define kQueueViewInactiveGradientEndingColor [NSColor colorWithDeviceWhite:0.88 alpha:1.f]
#define kQueueViewShadowStartingColor [NSColor colorWithDeviceWhite:0.f alpha:0.4f]
#define kQueueViewShadowEndingColor [NSColor clearColor]
#define kQueueViewShadowLength 3.f

@interface SNRQueueClipView : NSClipView
@end

@implementation SNRQueueClipView
- (void)drawRect:(NSRect)dirtyRect
{
    BOOL drawAsActive = [[self window] drawAsActive];
    NSRect fillRect = NSMakeRect(dirtyRect.origin.x, 0.f, dirtyRect.size.width, [self bounds].size.height);
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:drawAsActive? kQueueViewGradientStartingColor : kQueueViewInactiveGradientStartingColor endingColor:drawAsActive ? kQueueViewGradientEndingColor : kQueueViewInactiveGradientEndingColor];
    [gradient drawInRect:fillRect angle:270];
    [[SNRSharedImageCache sharedInstance] drawNoiseImage];
    NSGradient *shadow = [[NSGradient alloc] initWithStartingColor:kQueueViewShadowStartingColor endingColor:kQueueViewShadowEndingColor];
    NSRect shadowRect = fillRect;
    shadowRect.size.height = kQueueViewShadowLength;
    [shadow drawInRect:shadowRect angle:90];
}
@end

@implementation SNRQueueScrollView {
    SNRQueueClipView *_clipView;
}
@synthesize blockScrollEvents = _blockScrollEvents;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        id docView = [self documentView];
        _clipView = [[SNRQueueClipView alloc] initWithFrame:
                     [[self contentView] frame]];
        [self setContentView:_clipView];
        [self setDocumentView:docView];
    }
    return self;
}

- (void)scrollWheel:(NSEvent *)theEvent
{
    if (!self.blockScrollEvents) {
        [super scrollWheel:theEvent];
    }
}

@end
