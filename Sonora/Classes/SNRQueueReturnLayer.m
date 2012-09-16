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

#import "SNRQueueReturnLayer.h"

static NSString* const kImageArrowLeft = @"queue-return-left";
static NSString* const kImageArrowRight = @"queue-return-right";

@implementation SNRQueueReturnLayer {
    CAGradientLayer *_gradientLayer;
    CALayer *_imageLayer;
}
@synthesize showRightArrow = _showRightArrow;
@synthesize mouseUpBlock = _mouseUpBlock;

- (id)init
{
    if ((self = [super init])) {
        self.opaque = NO;
        self.backgroundColor = CGColorGetConstantColor(kCGColorClear);
        self.interactive = YES;
        _gradientLayer = [CAGradientLayer layer];
        CGColorRef gradientLeft = CGColorCreateGenericGray(0.f, 0.8f);
        CGColorRef gradientRight = CGColorGetConstantColor(kCGColorClear);
        _gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)gradientLeft, (__bridge id)gradientRight, nil];
        CGColorRelease(gradientLeft);
        _gradientLayer.startPoint = CGPointMake(0.f, 0.5f);
        _gradientLayer.endPoint = CGPointMake(1.f, 0.5f);
        _imageLayer = [CALayer layer];
        NSImage *arrowImage = [NSImage imageNamed:kImageArrowLeft];
        NSSize arrowSize = [arrowImage size];
        _imageLayer.contents = arrowImage;
        _imageLayer.bounds = CGRectMake(0.f, 0.f, arrowSize.width, arrowSize.height);
        [self addSublayer:_gradientLayer];
        [self addSublayer:_imageLayer];
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    [_gradientLayer setFrame:[self bounds]];
    CGRect newImageFrame = [_imageLayer frame];
    newImageFrame.origin.x = floor(CGRectGetMidX([self bounds]) - (newImageFrame.size.width / 2.f));
    newImageFrame.origin.y = floor(CGRectGetMidY([self bounds]) - (newImageFrame.size.height / 2.f));
    [_imageLayer setFrame:newImageFrame];
}

- (CALayer*)hitTest:(CGPoint)p
{
    if(CGRectContainsPoint([self frame], p))
        return self;
    return nil;
}

#pragma mark - Accessors

- (void)setShowRightArrow:(BOOL)showRightArrow
{
    if (_showRightArrow != showRightArrow) {
        _showRightArrow = showRightArrow;
        _imageLayer.contents = [NSImage imageNamed:_showRightArrow ? kImageArrowRight : kImageArrowLeft];
        _gradientLayer.startPoint = CGPointMake(_showRightArrow ? 1.f : 0.f, 0.5f);
        _gradientLayer.endPoint = CGPointMake(_showRightArrow ? 0.f : 1.f, 0.5f);
    }
}

#pragma mark - Mouse Events

- (void)mouseDownAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    if (self.hidden) { return; }
    self.tracking = YES;
    CGColorRef gradientLeft = CGColorCreateGenericGray(0.f, 0.95f);
    CGColorRef gradientRight = CGColorGetConstantColor(kCGColorClear);
    _gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)gradientLeft, (__bridge id)gradientRight, nil];
    CGColorRelease(gradientLeft);
}

- (void)mouseUpAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    if (self.hidden) { return; }
    self.tracking = NO;
    CGColorRef gradientLeft = CGColorCreateGenericGray(0.f, 0.8f);
    CGColorRef gradientRight = CGColorGetConstantColor(kCGColorClear);
    _gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)gradientLeft, (__bridge id)gradientRight, nil];
    CGColorRelease(gradientLeft);
    if (self.mouseUpBlock) {
        self.mouseUpBlock(self);
    }
}
@end
