//
//  SNRQueueProgressLayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-25.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRQueueProgressLayer.h"
#import "SNRGraphicsHelpers.h"

#define kProgressCornerRadius 4.f

@implementation SNRQueueProgressLayer

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
    CGColorRef progressTop = CGColorCreateGenericRGB(0.f, 0.32f, 0.67f, 0.8f);
    CGColorRef progressBottom = CGColorCreateGenericRGB(0.f, 0.14f, 0.37f, 0.8f);
    CGColorRef highlight = CGColorCreateGenericGray(1.f, 0.15f);
    SNRCGContextAddRoundedRectWithCorners(ctx, [self bounds], kProgressCornerRadius, SNRCGPathRoundedCornerTopLeft | SNRCGPathRoundedCornerTopRight);
    CGContextClip(ctx);
    CFArrayRef colors = (__bridge CFArrayRef)[NSArray arrayWithObjects:(__bridge id)progressTop, (__bridge id)progressBottom, nil];
    CGFloat locations[2] = {0.0, 1.0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, colors, locations);
    CGPoint startPoint = CGPointMake(CGRectGetMidX([self bounds]), 0.f);
    CGPoint endPoint = CGPointMake(startPoint.x, CGRectGetMaxY([self bounds]));
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGRect highlightRect = [self bounds];
    highlightRect.size.height = 1.f;
    CGContextSetFillColorWithColor(ctx, highlight);
    CGContextFillRect(ctx, highlightRect);
    CGColorSpaceRelease(colorSpace);
    CGColorRelease(progressTop);
    CGColorRelease(progressBottom);
    CGColorRelease(highlight);
}

@end
