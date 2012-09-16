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

#import "SNRQueueTextLayer.h"
#import "SNRQueueProgressLayer.h"
#import "SNRGraphicsHelpers.h"

#define kTextShadowBlurRadius 1.f
#define kTextShadowOpacity 0.75f
#define kTextShadowColor CGColorGetConstantColor(kCGColorBlack)
#define kTextShadowOffset CGSizeMake(0.f, 1.f)
#define kLayoutTextYInset 2.f
#define kLayoutTextXInset 6.f
#define kTextBackgroundCornerRadius 4.f

#define kScrollAnimationDurationPerChar 0.07f

@interface SNRQueueNoHitTextLayer : CATextLayer
@end

@implementation SNRQueueNoHitTextLayer

- (CALayer*)hitTest:(CGPoint)p
{
    return nil;
}

@end

@interface SNRQueueNoHitScrollLayer : CAScrollLayer
@end

@implementation SNRQueueNoHitScrollLayer

- (CALayer*)hitTest:(CGPoint)p
{
    return nil;
}

@end

@interface SNRQueueTextLayer ()
- (void)layoutSongScrollLayer;
@end

@implementation SNRQueueTextLayer {
    CATextLayer *_songTextLayer;
    CATextLayer *_artistTextLayer;
    CATextLayer *_durationTextLayer;
    CAScrollLayer *_songScrollLayer;
    SNRQueueProgressLayer *_progressLayer;
    CABasicAnimation *_scrollAnimation;
}
@synthesize songTextLayer = _songTextLayer;
@synthesize artistTextLayer = _artistTextLayer;
@synthesize durationTextLayer = _durationTextLayer;
@synthesize maxValue = _maxValue;
@synthesize doubleValue = _doubleValue;
@synthesize scrubbingBlock = _scrubbingBlock;
@synthesize hoverBlock = _hoverBlock;

- (id)init
{
    if ((self = [super init])) {
        self.backgroundColor = CGColorGetConstantColor(kCGColorClear);
        self.opaque = NO;
        self.needsDisplayOnBoundsChange = YES;
        self.receivesHoverEvents = YES;
        _artistTextLayer = [SNRQueueNoHitTextLayer layer];
        _artistTextLayer.font = (__bridge CFTypeRef)[NSFont boldSystemFontOfSize:10.f];
        _artistTextLayer.fontSize = 10.f;
        _artistTextLayer.shadowColor = CGColorGetConstantColor(kCGColorBlack);
        _artistTextLayer.shadowRadius = kTextShadowBlurRadius;
        _artistTextLayer.shadowOpacity = kTextShadowOpacity;
        _artistTextLayer.shadowOffset = kTextShadowOffset;
        _artistTextLayer.truncationMode = kCATruncationEnd;
        _artistTextLayer.contentsScale = SONORA_SCALE_FACTOR;
        _artistTextLayer.delegate = self;
        CGColorRef gray = CGColorCreateGenericGray(0.53f, 1.f);
        _artistTextLayer.foregroundColor = gray;
        CGColorRelease(gray);
        _songScrollLayer = [SNRQueueNoHitScrollLayer layer];
        _songScrollLayer.contentsScale = SONORA_SCALE_FACTOR;
        _songScrollLayer.delegate = self;
        _songTextLayer = [SNRQueueNoHitTextLayer layer];
        _songTextLayer.font = (__bridge CFTypeRef)[NSFont boldSystemFontOfSize:11.f];
        _songTextLayer.fontSize = 11.f;
        _songTextLayer.shadowColor = CGColorGetConstantColor(kCGColorBlack);
        _songTextLayer.shadowRadius = kTextShadowBlurRadius;
        _songTextLayer.shadowOpacity = kTextShadowOpacity;
        _songTextLayer.shadowOffset = kTextShadowOffset;
        _songTextLayer.truncationMode = kCATruncationEnd;
        _songTextLayer.truncationMode = kCATruncationEnd;
        _songTextLayer.contentsScale = SONORA_SCALE_FACTOR;
        _songTextLayer.delegate = self;
        [_songScrollLayer addSublayer:_songTextLayer];
        _durationTextLayer = [SNRQueueNoHitTextLayer layer];
        _durationTextLayer.font = _artistTextLayer.font;
        _durationTextLayer.fontSize = _artistTextLayer.fontSize;
        _durationTextLayer.foregroundColor = _artistTextLayer.foregroundColor;
        _durationTextLayer.shadowColor = kTextShadowColor;
        _durationTextLayer.shadowRadius = kTextShadowBlurRadius;
        _durationTextLayer.shadowOpacity = kTextShadowOpacity;
        _durationTextLayer.shadowOffset = kTextShadowOffset;
        _durationTextLayer.contentsScale = SONORA_SCALE_FACTOR;
        _durationTextLayer.delegate = self;
        _progressLayer = [SNRQueueProgressLayer layer];
        _progressLayer.hidden = YES;
        [self addSublayer:_progressLayer];
        [self addSublayer:_artistTextLayer];
        [self addSublayer:_songScrollLayer];
        [self addSublayer:_durationTextLayer];
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    CGSize durationSize = _durationTextLayer.preferredFrameSize;
    CGRect durationRect = CGRectMake(CGRectGetMaxX([self bounds]) - (durationSize.width + kLayoutTextXInset), CGRectGetMaxY([self bounds]) - (durationSize.height + kLayoutTextYInset), durationSize.width, durationSize.height);
    CGRect artistRect = CGRectMake(kLayoutTextXInset, durationRect.origin.y, [self bounds].size.width - ((kLayoutTextXInset * 3.f) + durationRect.size.width), durationSize.height);
    CGRect progressRect = [self bounds];
    progressRect.size.height -= 1.f;
    progressRect.origin.y = 1.f;
    progressRect.size.width = (self.maxValue == 0.0) ? 0.0 : floor([self bounds].size.width * (self.doubleValue / self.maxValue));
    [_progressLayer setFrame:progressRect];
    [_artistTextLayer setFrame:artistRect];
    [_durationTextLayer setFrame:durationRect];
    [self layoutSongScrollLayer];
}

- (void)layoutSongScrollLayer
{
    CGFloat songHeight = _songTextLayer.preferredFrameSize.height;
    CGRect songRect = CGRectMake(kLayoutTextXInset, kLayoutTextYInset, [self bounds].size.width - (kLayoutTextXInset * 2.f), songHeight);
    [_songScrollLayer setFrame:songRect];
    CGRect textFrame = (_scrollAnimation != nil) ? CGRectMake(0.f, 0.f, _songTextLayer.preferredFrameSize.width, [_songScrollLayer bounds].size.height) : [_songScrollLayer bounds];
    [_songTextLayer setFrame:textFrame];
}

- (void)drawInContext:(CGContextRef)ctx
{
    // Create colors and gradients
    CGColorRef gradientBottom = CGColorCreateGenericGray(0.f, 0.85f);
    CGColorRef gradientTop = CGColorCreateGenericGray(self.tracking ? 0.11f : 0.18f, 0.85f);
    CGColorRef border = CGColorCreateGenericGray(0.f, 0.7f);
    CGColorRef highlight = CGColorCreateGenericGray(1.f, 0.1f);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGFloat locations[2] = {0.0, 1.0};
    CFArrayRef colors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)gradientTop, (__bridge id)gradientBottom, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
    
    // Create the clipping path
    SNRCGContextAddRoundedRectWithCorners(ctx, [self bounds], kTextBackgroundCornerRadius, SNRCGPathRoundedCornerTopLeft | SNRCGPathRoundedCornerTopRight);
    CGContextClip(ctx);
    
    // Draw the gradient
    CGPoint startPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
    CGPoint endPoint = CGPointMake(startPoint.x, CGRectGetMaxY(self.bounds));
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    
    // Draw the top border and highlight
    CGRect borderRect = CGRectMake(0.f, 0.f, self.bounds.size.width, 1.f);
    CGContextSetFillColorWithColor(ctx, border);
    CGContextFillRect(ctx, borderRect);
    borderRect.origin.y += 1.f;
    CGContextSetFillColorWithColor(ctx, highlight);
    CGContextFillRect(ctx, borderRect);
    CGColorRelease(gradientBottom);
    CGColorRelease(gradientTop);
    CGColorRelease(border);
    CGColorRelease(highlight);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

#pragma mark - Accessors

- (void)setDoubleValue:(double)doubleValue
{
    if (_doubleValue != doubleValue) {
        _doubleValue = doubleValue;
        if (!_doubleValue) {
            _progressLayer.hidden = YES;
        } else {
            _progressLayer.hidden = NO;
            [self setNeedsLayout];
        }
    }
}

- (void)setMaxValue:(double)maxValue
{
    if (_maxValue != maxValue) {
        _maxValue = maxValue;
        if (!_maxValue) {
            _progressLayer.hidden = YES;
        } else {
            _progressLayer.hidden = NO;
            [self setNeedsLayout];
        }
    }
}

#pragma mark - CALayer Delegate

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale
   fromWindow:(NSWindow *)window
{
    return YES;
}

#pragma mark - Mouse Events

- (void)mouseDownAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    self.tracking = self.scrubbingBlock != nil;
    [self mouseDraggedAtPointInLayer:point withEvent:theEvent];
}

- (void)mouseDraggedAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    self.doubleValue = MIN(MAX(point.x / [self bounds].size.width, 0.0), 1.0) * self.maxValue;
    self.scrubbingBlock(self);
}

- (void)mouseUpAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    self.tracking = NO;
}

- (void)mouseMovedAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    if (self.interactive && self.hoverBlock) { 
        double hoverValue = MIN(MAX(point.x / [self bounds].size.width, 0.0), 1.0) * self.maxValue;
        self.hoverBlock(self, hoverValue);
    }
    BOOL pointInRect = NSPointInRect(point, NSRectFromCGRect([_songScrollLayer frame]));
    if (!_scrollAnimation && pointInRect && _songTextLayer.preferredFrameSize.width > [_songScrollLayer bounds].size.width) {
        _scrollAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        _scrollAnimation.autoreverses = YES;
        _scrollAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _scrollAnimation.duration = [_songTextLayer.string length] * kScrollAnimationDurationPerChar;
        _scrollAnimation.repeatCount = HUGE_VALF;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        [self layoutSongScrollLayer];
        [CATransaction commit];
        _scrollAnimation.fromValue = [NSValue valueWithPoint:NSPointFromCGPoint([_songTextLayer position])];
        _scrollAnimation.toValue = [NSValue valueWithPoint:CGPointMake(-[_songTextLayer bounds].size.width/2.f + [_songScrollLayer bounds].size.width, [_songTextLayer position].y)];
        [_songTextLayer addAnimation:_scrollAnimation forKey:@"position"];
    } else if (_scrollAnimation && !pointInRect) {
        [_songTextLayer removeAnimationForKey:@"position"];
        _scrollAnimation = nil;
        [self setNeedsLayout];
    }
}

- (void)mouseExitedAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    if (self.interactive && self.hoverBlock) {
        self.hoverBlock(self, 0.0);
    }
    if (_scrollAnimation) {
         [_songTextLayer removeAnimationForKey:@"position"];
        _scrollAnimation = nil;
        [self setNeedsLayout];
    }
}
@end
