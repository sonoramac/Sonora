//
//  CALayer+SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
