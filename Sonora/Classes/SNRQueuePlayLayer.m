//
//  SNRQueuePlayLayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-24.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
