//
//  SNRAlbumPlayLayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
