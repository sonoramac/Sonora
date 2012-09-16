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

#import "SNRAlbumGenericLayer.h"

#define kTextVerticalSpacing 2.f
#define kTextHorizontalInset 15.f
#define kTextShadowBlurRadius 1.f
#define kTextShadowOpacity 0.70f
#define kTextShadowColor CGColorGetConstantColor(kCGColorWhite)
#define kTextShadowOffset CGSizeMake(0.f, 1.f)

@implementation SNRAlbumGenericLayer {
    CATextLayer *_albumTextLayer;
    CATextLayer *_artistTextLayer;
    CAGradientLayer *_gradientLayer;
}
@synthesize albumTextLayer = _albumTextLayer;
@synthesize artistTextLayer = _artistTextLayer;

- (id)init
{
    if ((self = [super init])) {
        _gradientLayer = [CAGradientLayer layer];
        CGColorRef top = CGColorCreateGenericGray(0.98f, 1.f);
        CGColorRef bottom  = CGColorCreateGenericGray(0.89f, 1.f);
        _gradientLayer.colors = [NSArray arrayWithObjects:(__bridge id)top, (__bridge id)bottom, nil];
        CGColorRelease(top);
        CGColorRelease(bottom);
        _gradientLayer.contentsScale = SONORA_SCALE_FACTOR;
        _gradientLayer.delegate = self;
        _albumTextLayer = [CATextLayer layer];
        _albumTextLayer.font = (__bridge CFTypeRef)[NSFont boldSystemFontOfSize:16.f];
        _albumTextLayer.fontSize = 16.f;
        CGColorRef albumTextColor = CGColorCreateGenericGray(0.22f, 1.f);
        _albumTextLayer.foregroundColor = albumTextColor;
        CGColorRelease(albumTextColor);
        _albumTextLayer.truncationMode = kCATruncationEnd;
        _albumTextLayer.alignmentMode = kCAAlignmentCenter;
        _albumTextLayer.shadowRadius = kTextShadowBlurRadius;
        _albumTextLayer.shadowOpacity = kTextShadowOpacity;
        _albumTextLayer.shadowColor = kTextShadowColor;
        _albumTextLayer.shadowOffset = kTextShadowOffset;
        _albumTextLayer.contentsScale = SONORA_SCALE_FACTOR;
        _albumTextLayer.delegate = self;
        _artistTextLayer = [CATextLayer layer];
        _artistTextLayer.contentsScale = SONORA_SCALE_FACTOR;
        _artistTextLayer.delegate = self;
        _artistTextLayer.font = (__bridge CFTypeRef)[NSFont boldSystemFontOfSize:11.f];
        _artistTextLayer.fontSize = 11.f;
        CGColorRef artistTextColor = CGColorCreateGenericGray(0.46f, 1.f);
        _artistTextLayer.foregroundColor = artistTextColor;
        CGColorRelease(artistTextColor);
        _artistTextLayer.truncationMode = kCATruncationEnd;
        _artistTextLayer.alignmentMode = kCAAlignmentCenter;
        _artistTextLayer.shadowRadius = kTextShadowBlurRadius;
        _artistTextLayer.shadowOpacity = kTextShadowOpacity;
        _artistTextLayer.shadowColor = kTextShadowColor;
        _artistTextLayer.shadowOffset = kTextShadowOffset;
        [self addSublayer:_gradientLayer];
        [self addSublayer:_albumTextLayer];
        [self addSublayer:_artistTextLayer];
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [_gradientLayer setFrame:[self bounds]];
    CGFloat albumTextHeight = _albumTextLayer.preferredFrameSize.height;
    CGFloat artistTextHeight = _artistTextLayer.preferredFrameSize.height;
    CGFloat totalTextHeight = albumTextHeight + artistTextHeight + kTextVerticalSpacing;
    CGRect albumTextFrame = CGRectMake(kTextHorizontalInset, CGRectGetMidY([self bounds]) - (totalTextHeight / 2.f), [self bounds].size.width - (kTextHorizontalInset * 2.f), albumTextHeight);
    CGRect artistTextFrame = albumTextFrame;
    artistTextFrame.origin.y += kTextVerticalSpacing + albumTextHeight;
    artistTextFrame.size.height = artistTextHeight;
    [_albumTextLayer setFrame:CGRectIntegral(albumTextFrame)];
    [_artistTextLayer setFrame:CGRectIntegral(artistTextFrame)];
    [CATransaction commit];
}

#pragma mark - CALayer Delegate

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale
   fromWindow:(NSWindow *)window
{
    return YES;
}
@end
