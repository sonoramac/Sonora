//
//  SNRQueueShineLayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-23.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRQueueShineLayer.h"
#import "SNRGraphicsHelpers.h"

#define kShineCornerRadius 4.f

@implementation SNRQueueShineLayer

- (id)init
{
    if ((self = [super init])) {
        self.opaque = NO;
        self.backgroundColor = CGColorGetConstantColor(kCGColorClear);
        self.needsDisplayOnBoundsChange = YES;
    }
    return self;
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGFloat maxX = CGRectGetMaxX([self bounds]);
    CGFloat maxY = CGRectGetMaxY([self bounds]);
    CGColorRef shineColor = CGColorCreateGenericGray(1.f, 0.2f);
    CGColorRef clearColor = CGColorCreateGenericGray(1.f, 0.f);
    CGContextSaveGState(ctx);
    CGContextMoveToPoint(ctx, 0.f, 1.f);
    CGContextAddLineToPoint(ctx, maxX, 1.f);
    CGContextAddLineToPoint(ctx, 0.f, maxY - 2.f);
    CGContextClosePath(ctx);
    CGContextClip(ctx);
    SNRCGContextAddRoundedRect(ctx, [self bounds], kShineCornerRadius);
    CGFloat locations[2] = {0.0, 1.0};
    CFArrayRef colors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)shineColor, (__bridge id)clearColor, nil];
    CGPoint startPoint = CGPointMake(maxX, 0.f);
    CGPoint endPoint = CGPointMake(0.f, maxY);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGColorRelease(shineColor);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    CGContextRestoreGState(ctx);
    
    CGColorRef lightColor = CGColorCreateGenericGray(1.f, 0.6f);
    CGRect highlightRect = [self bounds];
    highlightRect.size.height = 1.f;
    CGContextSetFillColorWithColor(ctx, lightColor);
    SNRCGContextAddRoundedRect(ctx, CGRectInset([self bounds], 0.5f, 0.5f), kShineCornerRadius);
    CGContextClip(ctx);
    CGContextFillRect(ctx, highlightRect);
    CGColorRelease(lightColor);
    CGColorRelease(clearColor);
}
@end
