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
