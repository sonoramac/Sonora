//
//  SNRQueueAnimationContainer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-19.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRQueueAnimationContainer.h"

#import "NSView-SNRAdditions.h"
#import "CALayer+SNRAdditions.h"

@implementation SNRQueueAnimationContainer {
    CALayer *_animationLayer;
    CALayer *_topLayer;
    CALayer *_bottomLayer;
}
@synthesize animationView = _animationView;
@synthesize direction = _direction;

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        [self setLayer:[CALayer layer]];
        [self setWantsLayer:YES];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _animationLayer = [CALayer layer];
        [_animationLayer setFrame:[[self layer] bounds]];
        [_animationLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
        [_animationLayer setMasksToBounds:YES];
        [[self layer] addSublayer:_animationLayer];
        [CATransaction commit];
    }
    return self;
}

- (void)renderBottomLayer
{
    NSImage *viewImage = [self.animationView NSImage];
    _bottomLayer = [CALayer layer];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_bottomLayer setFrame:[_animationLayer bounds]];
    [_bottomLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
    [_bottomLayer setContents:viewImage];
    if (!_topLayer)
        [_animationLayer addSublayer:_bottomLayer];
    [CATransaction commit];
}

- (void)renderTopLayer
{
    NSImage *newViewImage = [self.animationView NSImage];
    _topLayer = [CALayer layer];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_topLayer setAutoresizingMask:kCALayerWidthSizable | kCALayerHeightSizable];
    [_topLayer setFrame:[_animationLayer bounds]];
    [_topLayer setShadowColor:CGColorGetConstantColor(kCGColorBlack)];
    [_topLayer setShadowOpacity:0.5f];
    [_topLayer setShadowRadius:4.f];
    [_topLayer setContents:newViewImage];
    [CATransaction commit];
}

- (void)animate
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGRect oldFrame = [_animationLayer bounds];
    BOOL left = (self.direction == SNRQueueAnimationDirectionLeft);
    oldFrame.origin.x = CGRectGetMaxX(oldFrame);
    CGRect newFrame = left ? [_animationLayer bounds] : oldFrame;
    if (left)
        [_topLayer setFrame:oldFrame];
    [_animationLayer addSublayer:_topLayer];
    [CATransaction commit];
    [_topLayer animateFromFrame:[_topLayer frame] toFrame:newFrame duration:0.5f timingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [_topLayer setFrame:newFrame];
}
@end
