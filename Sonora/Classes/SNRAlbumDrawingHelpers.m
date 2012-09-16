//
//  SNRAlbumDrawingHelpers.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-19.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRAlbumDrawingHelpers.h"

void drawGradientBackgroundInContext(CGContextRef ctx, CGRect bounds, BOOL tracking)
{
    // Create colors and gradients
    CGColorRef gradientBottom = CGColorCreateGenericGray(0.f, 0.85f);
    CGColorRef gradientTop = CGColorCreateGenericGray(tracking ? 0.11f : 0.18f, 0.85f);
    CGColorRef border = CGColorCreateGenericGray(0.f, 0.7f);
    CGColorRef highlight = CGColorCreateGenericGray(1.f, 0.1f);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    CGFloat locations[2] = {0.0, 1.0};
    CFArrayRef colors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)gradientTop, (__bridge id)gradientBottom, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
    
    // Draw the gradient
    CGPoint startPoint = CGPointMake(CGRectGetMidX(bounds), CGRectGetMinY(bounds));
    CGPoint endPoint = CGPointMake(startPoint.x, CGRectGetMaxY(bounds));
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    
    // Draw the top border and highlight
    CGRect borderRect = CGRectMake(0.f, 0.f, bounds.size.width, 1.f);
    CGContextSetFillColorWithColor(ctx, border);
    CGContextFillRect(ctx, borderRect);
    borderRect.origin.y += 1.f;
    CGContextSetFillColorWithColor(ctx, highlight);
    CGContextFillRect(ctx, borderRect);
    CGColorRelease(gradientBottom);
    CGColorRelease(gradientTop);
    CGColorRelease(border);
    CGColorRelease(highlight);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}