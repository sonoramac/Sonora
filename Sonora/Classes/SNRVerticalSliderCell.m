//
//  SNRVerticalSliderCell.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-05-18.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRVerticalSliderCell.h"

static NSString* const kImageBottom = @"slider-filled-bottom";
static NSString* const kImageTop = @"slider-empty-top";
static NSString* const kImageMidFilled = @"slider-filled-mid";
static NSString* const kImageMidEmpty = @"slider-empty-mid";
static NSString* const kImageKnob = @"slider-knob";
static NSString* const kImageKnobHighlighted = @"slider-knob-h";

@implementation SNRVerticalSliderCell

- (void)drawKnob:(NSRect)knobRect
{
    knobRect.origin.x -= 1.f;
    NSImage *knob = [NSImage imageNamed:[self isHighlighted] ? kImageKnobHighlighted : kImageKnob];
    [knob setFlipped:YES];
    [knob drawInRect:knobRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.f];
}

- (BOOL)_usesCustomTrackImage
{
    return YES;
}

- (void)drawBarInside:(NSRect)aRect flipped:(BOOL)flipped
{
    NSImage *top = [NSImage imageNamed:kImageTop];
    NSImage *mid = [NSImage imageNamed:kImageMidEmpty];
    NSImage *bottom = [NSImage imageNamed:kImageBottom];
    NSSize bottomSize = bottom.size;
    NSRect barRect = NSMakeRect(floor(NSMidX(aRect) - (bottomSize.width / 2.f)), aRect.origin.y, bottomSize.width, aRect.size.height);
    NSDrawThreePartImage(barRect, top, mid, bottom, YES, NSCompositeSourceOver, 1.f, flipped);
    NSRect knobRect = [self knobRectFlipped:flipped];
    NSImage *fill = [NSImage imageNamed:kImageMidFilled];
    CGFloat fillHeight = aRect.size.height - (NSMidY(knobRect) + bottomSize.height);
    NSRect fillRect = NSMakeRect(barRect.origin.x, NSMaxY(barRect) - fillHeight, barRect.size.width, fillHeight - bottomSize.height);
    NSDrawThreePartImage(fillRect, nil, fill, nil, YES, NSCompositeSourceOver, 1.f, flipped);
}

@end

@implementation SNRVerticalSlider
// Need it to redraw the whole slider every time otherwise it causes drawing artifacts
- (void)setNeedsDisplayInRect:(NSRect)invalidRect
{
    [super setNeedsDisplayInRect:self.bounds];
}
@end
