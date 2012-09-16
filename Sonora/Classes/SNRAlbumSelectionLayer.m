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
#import "SNRAlbumSelectionLayer.h"
#import "SNRGraphicsHelpers.h"

#define kSelectionWidth 6.f
#define kSelectionCornerRadius 4.f
#define kSelectionShadowColor CGColorGetConstantColor(kCGColorBlack)
#define kSelectionShadowOpacity 0.6f
#define kSelectionShadowBlurRadius 2.f
#define kSelectionShadowOffset CGSizeMake(0.f, 3.f)

@implementation SNRAlbumSelectionLayer

- (id)init
{
    if ((self = [super init])) {
        self.opaque = NO;
        self.backgroundColor = CGColorGetConstantColor(kCGColorClear);
        self.needsDisplayOnBoundsChange = YES;
        self.shadowColor = kSelectionShadowColor;
        self.shadowOpacity = kSelectionShadowOpacity;
        self.shadowRadius = kSelectionShadowBlurRadius;
        self.shadowOffset = kSelectionShadowOffset;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    // Create gradients and colors
    CGColorRef gradientBottom = CGColorCreateGenericRGB(0.f, 0.39f, 0.75f, 1.f);
    CGColorRef gradientTop = CGColorCreateGenericRGB(0.22f, 0.56f, 0.91f, 1.f);
    CGColorRef strokeBottom = CGColorCreateGenericRGB(0.f, 0.31f, 0.58f, 1.f);
    CGColorRef strokeTop = CGColorCreateGenericRGB(0.13f, 0.54f, 0.83f, 1.f);
    CGColorRef highlight = CGColorCreateGenericRGB(1.f, 1.f, 1.f, 0.3f);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CFArrayRef innerColors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)gradientTop, (__bridge id)gradientBottom, nil];
    CFArrayRef outerColors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)strokeTop, (__bridge id)strokeBottom, nil];
    CGFloat locations[2] = {0.0, 1.0};
    CGGradientRef innerGradient = CGGradientCreateWithColors(colorSpace, innerColors, locations);
    CGGradientRef outerGradient = CGGradientCreateWithColors(colorSpace, outerColors, locations);
    CGRect outerRect = self.bounds;
    CGRect innerRect = CGRectInset(outerRect, 1.f, 1.f);
    CGPoint outerStartPoint = CGPointMake(CGRectGetMidX(outerRect), CGRectGetMinY(outerRect));
    CGPoint outerEndPoint = CGPointMake(CGRectGetMidX(outerRect), CGRectGetMaxY(outerRect));
    CGPoint innerStartPoint = CGPointMake(CGRectGetMidX(innerRect), CGRectGetMinY(innerRect));
    CGPoint innerEndPoint = CGPointMake(CGRectGetMidX(innerRect), CGRectGetMaxY(innerRect));
    
    // Draw outer gradient (border)
    CGContextSaveGState(ctx);
    SNRCGContextAddRoundedRect(ctx, outerRect, kSelectionCornerRadius);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, outerGradient, outerStartPoint, outerEndPoint, 0);
    CGContextRestoreGState(ctx);
    
    // Draw inner gradient (fill)
    CGContextSaveGState(ctx);
    SNRCGContextAddRoundedRect(ctx, innerRect, kSelectionCornerRadius);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, innerGradient, innerStartPoint, innerEndPoint, 0);
    CGContextRestoreGState(ctx);
    
    // Draw the top highlight
    CGRect topHighlightRect = outerRect;
    topHighlightRect.size.height = kSelectionCornerRadius;
    CGRect squareRect = CGRectInset(self.bounds, kSelectionWidth, kSelectionWidth);
    CGRect bottomHighlightRect = squareRect;
    bottomHighlightRect.origin.y = CGRectGetMaxY(squareRect);
    bottomHighlightRect.size.height = 1.f;
    CGContextSaveGState(ctx);
    CGContextSetStrokeColorWithColor(ctx, highlight);
    CGContextSetFillColorWithColor(ctx, highlight);
    CGContextFillRect(ctx, bottomHighlightRect);
    CGContextClipToRect(ctx, topHighlightRect);
    SNRCGContextAddRoundedRect(ctx, CGRectInset(innerRect, 0.5f, 0.5f), kSelectionCornerRadius);
    CGContextStrokePath(ctx);
    CGContextRestoreGState(ctx);
    
    // Create a square hole that the artwork will show through
    CGContextSetFillColorWithColor(ctx, CGColorGetConstantColor(kCGColorClear));
    CGContextSetBlendMode(ctx, kCGBlendModeSourceIn); 
    CGContextFillRect(ctx, squareRect);
    
    // Release all the colors and gradients
    CGGradientRelease(innerGradient);
    CGGradientRelease(outerGradient);
    CGColorSpaceRelease(colorSpace);
    CGColorRelease(gradientBottom);
    CGColorRelease(gradientTop);
    CGColorRelease(strokeBottom);
    CGColorRelease(strokeTop);
    CGColorRelease(highlight);
}

@end
