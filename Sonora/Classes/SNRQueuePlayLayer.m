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
#import "SNRQueuePlayLayer.h"

#define kPlayButtonOuterStrokeWidth 2.f
#define kPlayButtonInnerStrokeWidth 3.f
#define kLayoutPlayGlyphInset 15.f
#define kLayoutPlayGlyphXOffset 2.f
#define kLayoutPauseGlyphInset 15.f
#define kLayoutPauseGlyphBarSpacing 4.f

@interface SNRQueuePlayLayer ()
- (void)drawPauseGlyphInContext:(CGContextRef)ctx;
- (void)drawPlayGlyphInContext:(CGContextRef)ctx;
@end

@implementation SNRQueuePlayLayer
@synthesize state = _state;
@synthesize mouseUpBlock = _mouseUpBlock;

- (id)init
{
    if ((self = [super init])) {
        self.needsDisplayOnBoundsChange = YES;
        self.opaque = NO;
        self.backgroundColor = CGColorGetConstantColor(kCGColorClear);
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGColorRef outerStroke = CGColorCreateGenericGray(0.f, 0.75f);
    CGColorRef innerStroke = CGColorCreateGenericGray(1.f, 0.85f);
    
    CGContextSetFillColorWithColor(ctx, outerStroke);
    CGContextFillEllipseInRect(ctx, [self bounds]);
    CGFloat inset = kPlayButtonOuterStrokeWidth + (kPlayButtonInnerStrokeWidth / 2.f);
    CGRect innerRect = CGRectInset([self bounds], inset, inset);
    CGContextSetStrokeColorWithColor(ctx, innerStroke);
    CGContextSetLineWidth(ctx, kPlayButtonInnerStrokeWidth);
    CGContextStrokeEllipseInRect(ctx, innerRect);
    
    CGColorRelease(outerStroke);
    CGColorRelease(innerStroke);
    
    self.state ? [self drawPauseGlyphInContext:ctx] : [self drawPlayGlyphInContext:ctx];
    
    if (self.tracking) {
        CGColorRef overlayColor = CGColorCreateGenericGray(0.f, 0.3f);
        CGContextSetFillColorWithColor(ctx, overlayColor);
        CGContextFillEllipseInRect(ctx, [self bounds]);
        CGColorRelease(overlayColor);
    }
}

- (void)drawPauseGlyphInContext:(CGContextRef)ctx
{
    CGRect pauseRect = CGRectInset([self bounds], kLayoutPauseGlyphInset, kLayoutPauseGlyphInset);
    CGFloat barWidth = floor((pauseRect.size.width - kLayoutPauseGlyphBarSpacing) / 2.f);
    CGRect leftBarRect = pauseRect;
    leftBarRect.size.width = barWidth;
    CGRect rightBarRect = leftBarRect;
    rightBarRect.origin.x = CGRectGetMaxX(pauseRect) - rightBarRect.size.width;
    CGContextSetFillColorWithColor(ctx, CGColorGetConstantColor(kCGColorWhite));
    CGContextFillRect(ctx, leftBarRect);
    CGContextFillRect(ctx, rightBarRect);
}

- (void)drawPlayGlyphInContext:(CGContextRef)ctx
{
    CGRect playRect = CGRectInset([self bounds], kLayoutPlayGlyphInset, kLayoutPlayGlyphInset);
    playRect.origin.x += kLayoutPlayGlyphXOffset;
    CGContextMoveToPoint(ctx, playRect.origin.x, playRect.origin.y);
    CGContextAddLineToPoint(ctx, playRect.origin.x, CGRectGetMaxY(playRect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(playRect), CGRectGetMidY(playRect));
    CGContextAddLineToPoint(ctx, playRect.origin.x, playRect.origin.y);
    CGContextSetFillColorWithColor(ctx, CGColorGetConstantColor(kCGColorWhite));
    CGContextFillPath(ctx);
}

#pragma mark - Mouse Events

- (void)mouseDownAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    self.tracking = YES;
    [self setNeedsDisplay];
}

- (void)mouseUpAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    self.tracking = NO;
    [self setNeedsDisplay];
    self.state = !self.state;
    if (self.mouseUpBlock) {
        self.mouseUpBlock(self);
    }
}

#pragma mark - Accessors

- (void)setState:(BOOL)state
{
    if (_state != state) {
        _state = state;
        [self setNeedsDisplay];
    }
}
@end
