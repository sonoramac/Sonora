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
