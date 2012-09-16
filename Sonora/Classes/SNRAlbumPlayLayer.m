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

#import "SNRAlbumPlayLayer.h"
#import "SNRAlbumDrawingHelpers.h"

#define kPlayGlyphWidth 13.f
#define kPlayGlyphHeight 12.f
#define kPlayGlyphShadowColor CGColorGetConstantColor(kCGColorBlack)
#define kPlayGlyphShadowBlurRadius 1.f
#define kPlayGlyphShadowOffset CGSizeMake(0.f, -1.f)

@implementation SNRAlbumPlayLayer

- (void)drawInContext:(CGContextRef)ctx
{
    // Create colors and gradients
    CGColorRef highlight = CGColorCreateGenericGray(1.f, 0.1f);
    CGColorRef playBottom = CGColorCreateGenericGray(0.88f, 1.f);
    CGColorRef playTop = CGColorCreateGenericGray(0.96f, 1.f);
    CGColorRef playStroke = CGColorCreateGenericGray(0.f, 0.75f);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGFloat locations[2] = {0.0, 1.0};
    CFArrayRef playColors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)playTop, (__bridge id)playBottom, nil];
    CGGradientRef playGradient = CGGradientCreateWithColors(colorSpace, playColors, locations);
    
    // Draw the gradient
    CGPoint startPoint = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMinY(self.bounds));
    CGPoint endPoint = CGPointMake(startPoint.x, CGRectGetMaxY(self.bounds));
    
    drawGradientBackgroundInContext(ctx, [self bounds], self.tracking);
    
    // Draw the right divider and highlight
    CGRect dividerRect = CGRectMake(CGRectGetMaxX(self.bounds) - 1.f, 0.f, 1.f, self.bounds.size.height);
    CGContextSetFillColorWithColor(ctx, CGColorGetConstantColor(kCGColorBlack));
    CGContextFillRect(ctx, dividerRect);
    dividerRect.origin.x -= 1.f;
    CGContextSetFillColorWithColor(ctx, highlight);
    CGContextFillRect(ctx, dividerRect);
    
    // Draw the play glyph
    CGRect glyphRect = CGRectIntegral(CGRectMake(CGRectGetMidX(self.bounds) - (kPlayGlyphWidth / 2.f), CGRectGetMidY(self.bounds) - (kPlayGlyphHeight / 2.f), kPlayGlyphWidth, kPlayGlyphHeight));
    startPoint = CGPointMake(CGRectGetMidX(glyphRect), CGRectGetMinY(glyphRect));
    endPoint = CGPointMake(startPoint.x, CGRectGetMaxY(glyphRect));
    CGContextMoveToPoint(ctx, CGRectGetMinX(glyphRect), CGRectGetMinY(glyphRect));
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(glyphRect), CGRectGetMidY(glyphRect));
    CGContextAddLineToPoint(ctx, CGRectGetMinX(glyphRect), CGRectGetMaxY(glyphRect));
    CGContextClosePath(ctx);
    CGContextSaveGState(ctx);
    CGContextClip(ctx);
    CGContextDrawLinearGradient(ctx, playGradient, startPoint, endPoint, 0);
    CGContextRestoreGState(ctx);
    CGContextMoveToPoint(ctx, CGRectGetMinX(glyphRect), CGRectGetMinY(glyphRect) - 1.f);
    CGContextAddLineToPoint(ctx, CGRectGetMaxX(glyphRect), CGRectGetMidY(glyphRect) - 1.f);
    CGContextSetStrokeColorWithColor(ctx, playStroke);
    CGContextStrokePath(ctx);

    // Release colors and gradients
    CGGradientRelease(playGradient);
    CGColorSpaceRelease(colorSpace);
    CGColorRelease(playTop);
    CGColorRelease(playBottom);
    CGColorRelease(highlight);
    CGColorRelease(playStroke);
}
@end
