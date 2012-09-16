//
//  SNRPopoverScroller.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-28.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRPopoverScroller.h"

@interface SNRPopoverScroller ()
- (void)commonInitForSNRPopoverScroller;
@end

@implementation SNRPopoverScroller

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        [self commonInitForSNRPopoverScroller];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInitForSNRPopoverScroller];
    }
    return self;
}

- (void)commonInitForSNRPopoverScroller
{
    self.scrollerStyle = NSScrollerStyleOverlay;
    self.controlSize = NSSmallControlSize;
}

+ (BOOL)isCompatibleWithOverlayScrollers
{
    return YES;
}

@end
