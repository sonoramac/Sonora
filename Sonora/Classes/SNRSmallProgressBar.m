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
#import "SNRSmallProgressBar.h"
#import "SNRGraphicsHelpers.h"

@interface SNRSmallProgressBar ()
- (void)layoutProgressLayer;
- (void)drawTrackLayerInContext:(CGContextRef)ctx;
- (void)drawProgressLayerInContext:(CGContextRef)ctx;
@end

@implementation SNRSmallProgressBar {
    CALayer *_trackLayer;
    CALayer *_progressLayer;
}

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        [self setWantsLayer:YES];
        CALayer *rootLayer = [CALayer layer];
        rootLayer.masksToBounds = YES;
        [self setLayer:rootLayer];
        [rootLayer setFrame:[self bounds]];
        _trackLayer = [CALayer layer];
        _trackLayer.contentsScale = SONORA_SCALE_FACTOR;
        _trackLayer.delegate = self;
        _trackLayer.needsDisplayOnBoundsChange = YES;
        _trackLayer.frame = [self bounds];
        _trackLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        _progressLayer = [CALayer layer];
        _progressLayer.contentsScale = SONORA_SCALE_FACTOR;
        _progressLayer.delegate = self;
        _progressLayer.needsDisplayOnBoundsChange = YES;
        _progressLayer.shadowColor = CGColorGetConstantColor(kCGColorBlack);
        _progressLayer.shadowOpacity = 0.5f;
        _progressLayer.shadowRadius = 1.f;
        _progressLayer.shadowOffset = CGSizeMake(1.f, 0.f);
        _progressLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
        [rootLayer addSublayer:_trackLayer];
        [rootLayer addSublayer:_progressLayer];
    }
    return self;
}

- (void)layoutProgressLayer
{
    CGRect progressRect = CGRectInset([_trackLayer bounds], 1.f, 1.f);
    progressRect.origin.y += 1.f;
    progressRect.size.height -= 1.f;
    progressRect.size.width = floor(([self doubleValue] / MAX(1.0, [self maxValue])) * (progressRect.size.width - progressRect.size.height)) + progressRect.size.height;
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    _progressLayer.frame = progressRect;
    [CATransaction commit];
}

#pragma mark - CALayer Delegate

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale
   fromWindow:(NSWindow *)window
{
    return YES;
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    if (layer == _trackLayer) {
        [self drawTrackLayerInContext:ctx];
    } else if (layer == _progressLayer) {
        [self drawProgressLayerInContext:ctx];
    }
}

- (void)drawTrackLayerInContext:(CGContextRef)ctx
{
    CGColorRef shadowColor = CGColorCreateGenericGray(1.f, 0.15f);
    CGRect shadowRect = [_trackLayer bounds];
    shadowRect.size.height -= 1.f;
    SNRCGContextAddRoundedRect(ctx, shadowRect, shadowRect.size.height / 2.f);
    CGContextSetFillColorWithColor(ctx, shadowColor);
    CGContextFillPath(ctx);
    CGColorRelease(shadowColor);
    
    CGFloat locations[2] = {0.0, 1.0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef strokeBottom = CGColorCreateGenericGray(0.35f, 1.f);
    CGColorRef strokeTop = CGColorCreateGenericGray(0.27f, 1.f);
    CFArrayRef strokeColors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)strokeBottom, (__bridge id)strokeTop, nil];
    CGGradientRef strokeGradient = CGGradientCreateWithColors(colorSpace, strokeColors, locations);
    CGRect strokeRect = shadowRect;
    strokeRect.origin.y += 1.f;
    CGFloat strokeRectMidX = CGRectGetMidX(strokeRect);
    CGContextSaveGState(ctx);
    SNRCGContextAddRoundedRect(ctx, strokeRect, strokeRect.size.height / 2.f);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, strokeGradient, CGPointMake(strokeRectMidX, CGRectGetMinY(strokeRect)), CGPointMake(strokeRectMidX, CGRectGetMaxY(strokeRect)), 0);
    CGContextRestoreGState(ctx);
    CGGradientRelease(strokeGradient);
    CGColorRelease(strokeBottom);
    CGColorRelease(strokeTop);
    
    CGColorRef trackBottom = CGColorCreateGenericGray(0.45f, 1.f);
    CGColorRef trackTop = CGColorCreateGenericGray(0.38f, 1.f);
    CFArrayRef trackColors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)trackBottom, (__bridge id)trackTop, nil];
    CGGradientRef trackGradient = CGGradientCreateWithColors(colorSpace, trackColors, locations);
    CGRect trackRect = CGRectInset(strokeRect, 1.f, 1.f);
    CGFloat trackRectMidX = CGRectGetMidX(trackRect);
    SNRCGContextAddRoundedRect(ctx, trackRect, trackRect.size.height / 2.f);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, trackGradient, CGPointMake(trackRectMidX, CGRectGetMinY(trackRect)), CGPointMake(trackRectMidX, CGRectGetMaxY(trackRect)), 0);
    CGGradientRelease(trackGradient);
    CGColorRelease(trackBottom);
    CGColorRelease(trackTop);
    CGColorSpaceRelease(colorSpace);
}

- (void)drawProgressLayerInContext:(CGContextRef)ctx
{
    CGFloat locations[2] = {0.0, 1.0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGColorRef fillBottom = CGColorCreateGenericGray(0.86f, 1.f);
    CGColorRef fillTop = CGColorCreateGenericGray(0.81f, 1.f);
    CFArrayRef fillColors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)fillBottom, (__bridge id)fillTop, nil];
    CGGradientRef fillGradient = CGGradientCreateWithColors(colorSpace, fillColors, locations);
    CGRect fillRect = [_progressLayer bounds];
    CGFloat fillRectMidX = CGRectGetMidX(fillRect);
    SNRCGContextAddRoundedRect(ctx, fillRect, fillRect.size.height / 2.f);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, fillGradient, CGPointMake(fillRectMidX, CGRectGetMinY(fillRect)), CGPointMake(fillRectMidX, CGRectGetMaxY(fillRect)), 0);
    CGGradientRelease(fillGradient);
    CGColorRelease(fillBottom);
    CGColorRelease(fillTop);
    CGColorSpaceRelease(colorSpace);
    
    CGColorRef highlightColor = CGColorCreateGenericGray(1.f, 0.8f);
    CGContextSetFillColorWithColor(ctx, highlightColor);
    fillRect.size.height = 1.f;
    fillRect.origin.y = CGRectGetMaxY([_progressLayer bounds]) - 1.f;
    CGContextFillRect(ctx, fillRect);
    CGColorRelease(highlightColor);
}

#pragma mark - Accessors

- (void)setDoubleValue:(double)doubleValue
{
    [super setDoubleValue:doubleValue];
    [self layoutProgressLayer];
}

- (void)setMaxValue:(double)newMaximum
{
    [super setMaxValue:newMaximum];
    [self layoutProgressLayer];
}
@end
