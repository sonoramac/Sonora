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

#import "SNRPopoverButtonCell.h"

#import "NSShadow-SNRAdditions.h"

#define kBackgroundGradientStartingColor [NSColor colorWithDeviceWhite:0.94f alpha:1.f]
#define kBackgroundGradientEndingColor [NSColor colorWithDeviceWhite:0.99f alpha:1.f]
#define kBorderColor [NSColor colorWithDeviceWhite:0.69f alpha:1.f]
#define kBorderCornerRadius 3.f
#define kTextColor [NSColor colorWithDeviceWhite:0.4f alpha:1.f]
#define kTextFont [NSFont systemFontOfSize:11.f]
#define kTextShadowBlurRadius 1.f
#define kTextShadowOffset NSMakeSize(0.f, 1.f)
#define kTextShadowColor [NSColor colorWithDeviceWhite:1.f alpha:0.75f]
#define kHighlightedOverlayColor [NSColor colorWithDeviceWhite:0.f alpha:0.3f]

@implementation SNRPopoverButtonCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect drawingRect = NSInsetRect(cellFrame, 0.5f, 0.5f);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:drawingRect xRadius:kBorderCornerRadius yRadius:kBorderCornerRadius];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:kBackgroundGradientStartingColor endingColor:kBackgroundGradientEndingColor];
    [gradient drawInBezierPath:path angle:270.f];
    [kBorderColor set];
    [path stroke];
    NSShadow *shadow = [NSShadow shadowWithOffset:kTextShadowOffset blurRadius:kTextShadowBlurRadius color:kTextShadowColor];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:kTextColor, NSForegroundColorAttributeName, kTextFont, NSFontAttributeName, shadow, NSShadowAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[self title] attributes:attributes];
    NSSize titleSize = [title size];
    NSRect textRect = NSMakeRect(0.f, NSMidY(cellFrame) - (titleSize.height / 2.f), cellFrame.size.width, titleSize.height);
    [title drawInRect:textRect];
    if ([self isHighlighted]) {
        [kHighlightedOverlayColor set];
        [path fill];
    }
}

@end
