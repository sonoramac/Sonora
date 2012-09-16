/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
