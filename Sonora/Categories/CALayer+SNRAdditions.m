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
#import "CALayer+SNRAdditions.h"
#import "SNRGraphicsHelpers.h"

@implementation CALayer (SNRAdditions)
- (void)animateFromFrame:(CGRect)frame toFrame:(CGRect)newFrame duration:(NSTimeInterval)duration timingFunction:(CAMediaTimingFunction*)timingFunction
{
    CABasicAnimation *boundsAnimation = [CABasicAnimation animation];
    boundsAnimation.duration = duration;
    boundsAnimation.timingFunction = timingFunction;
    NSRect newBounds = NSRectFromCGRect(newFrame);
    newBounds.origin = NSZeroPoint;
    NSRect oldBounds = NSRectFromCGRect(frame);
    oldBounds.origin = NSZeroPoint;
    boundsAnimation.toValue = [NSValue valueWithRect:newBounds];
    boundsAnimation.fromValue = [NSValue valueWithRect:oldBounds];
    CABasicAnimation *positionAnimation = [CABasicAnimation animation];
    positionAnimation.duration = duration;
    positionAnimation.timingFunction = timingFunction;
    NSPoint oldPosition = NSMakePoint(CGRectGetMidX(frame), CGRectGetMidY(frame));
    NSPoint newPosition = NSMakePoint(CGRectGetMidX(newFrame), CGRectGetMidY(newFrame));
    positionAnimation.fromValue = [NSValue valueWithPoint:oldPosition];
    positionAnimation.toValue = [NSValue valueWithPoint:newPosition];
    [self addAnimation:boundsAnimation forKey:@"bounds"];
    [self addAnimation:positionAnimation forKey:@"position"];
}

- (void)animateOpacityFrom:(CGFloat)opacity toOpacity:(CGFloat)newOpacity duration:(NSTimeInterval)duration timingFunction:(CAMediaTimingFunction*)timingFunction
{
    CABasicAnimation *opacityAnimation = [CABasicAnimation animation];
    opacityAnimation.duration = duration;
    opacityAnimation.timingFunction = timingFunction;
    opacityAnimation.fromValue = [NSNumber numberWithDouble:opacity];
    opacityAnimation.toValue = [NSNumber numberWithDouble:newOpacity];
    [self addAnimation:opacityAnimation forKey:@"opacity"];
}

- (NSImage*)NSImage
{
    CGContextRef ctx = SNRCGContextCreateWithSize([self bounds].size);
    [self renderInContext:ctx];
    CGImageRef image = CGBitmapContextCreateImage(ctx);
    NSImage *newImage = [[NSImage alloc] initWithCGImage:image size:NSZeroSize];
    CGImageRelease(image);
    CGContextRelease(ctx);
    return newImage;
}
@end
