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