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

#import "SNRAlbumTextLayer.h"
#import "SNRAlbumDrawingHelpers.h"

#define kTextShadowBlurRadius 1.f
#define kTextShadowOpacity 0.75f
#define kTextShadowColor CGColorGetConstantColor(kCGColorBlack)
#define kTextShadowOffset CGSizeMake(0.f, -1.f)
#define kLayoutTextYInset 4.f
#define kLayoutTextXInset 6.f

@implementation SNRAlbumTextLayer {
    CATextLayer *_albumTextLayer;
    CATextLayer *_artistTextLayer;
    CATextLayer *_durationTextLayer;
}
@synthesize albumTextLayer = _albumTextLayer;
@synthesize artistTextLayer = _artistTextLayer;
@synthesize durationTextLayer = _durationTextLayer;

- (id)init
{
    if ((self = [super init])) {
        self.backgroundColor = CGColorGetConstantColor(kCGColorClear);
        self.opaque = NO;
        self.needsDisplayOnBoundsChange = YES;
        self.masksToBounds = YES;
        _albumTextLayer = [CATextLayer layer];
        _albumTextLayer.font = (__bridge CFTypeRef)[NSFont boldSystemFontOfSize:12.f];
        _albumTextLayer.fontSize = 12.f;
        _albumTextLayer.shadowColor = CGColorGetConstantColor(kCGColorBlack);
        _albumTextLayer.shadowRadius = kTextShadowBlurRadius;
        _albumTextLayer.shadowOpacity = kTextShadowOpacity;
        _albumTextLayer.shadowOffset = kTextShadowOffset;
        _albumTextLayer.truncationMode = kCATruncationEnd;
        _albumTextLayer.contentsScale = SONORA_SCALE_FACTOR;
        _albumTextLayer.delegate = self;
        _artistTextLayer = [CATextLayer layer];
        _artistTextLayer.font = (__bridge CFTypeRef)[NSFont boldSystemFontOfSize:11.f];
        _artistTextLayer.fontSize = 11.f;
        _artistTextLayer.shadowColor = CGColorGetConstantColor(kCGColorBlack);
        _artistTextLayer.shadowRadius = kTextShadowBlurRadius;
        _artistTextLayer.shadowOpacity = kTextShadowOpacity;
        _artistTextLayer.shadowOffset = kTextShadowOffset;
        _artistTextLayer.contentsScale = SONORA_SCALE_FACTOR;
        _artistTextLayer.delegate = self;
        CGColorRef gray = CGColorCreateGenericGray(0.53f, 1.f);
        _artistTextLayer.foregroundColor = gray;
        CGColorRelease(gray);
        _artistTextLayer.truncationMode = kCATruncationEnd;
        _durationTextLayer = [CATextLayer layer];
        _durationTextLayer.font = _artistTextLayer.font;
        _durationTextLayer.fontSize = _artistTextLayer.fontSize;
        _durationTextLayer.shadowColor = CGColorGetConstantColor(kCGColorBlack);;
        _durationTextLayer.shadowRadius = kTextShadowBlurRadius;
        _durationTextLayer.shadowOpacity = kTextShadowOpacity;
        _durationTextLayer.shadowOffset = kTextShadowOffset;
        _durationTextLayer.foregroundColor = _artistTextLayer.foregroundColor;
        _durationTextLayer.contentsScale = SONORA_SCALE_FACTOR;
        _durationTextLayer.delegate = self;
        [self addSublayer:_albumTextLayer];
        [self addSublayer:_artistTextLayer];
        [self addSublayer:_durationTextLayer];
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    CGSize durationSize = _durationTextLayer.preferredFrameSize;
    CGRect durationRect = CGRectMake(CGRectGetMaxX([self bounds]) - (durationSize.width + kLayoutTextXInset), CGRectGetMaxY([self bounds]) - (durationSize.height + kLayoutTextYInset), durationSize.width, durationSize.height);
    CGFloat albumHeight = _albumTextLayer.preferredFrameSize.height;
    CGRect albumRect = CGRectMake(kLayoutTextXInset, kLayoutTextYInset, [self bounds].size.width - (kLayoutTextXInset * 2.f), albumHeight);
    CGRect artistRect = CGRectMake(kLayoutTextXInset, durationRect.origin.y, [self bounds].size.width - ((kLayoutTextXInset * 3.f) + durationRect.size.width), durationSize.height);
    if (![_artistTextLayer.string length]) {
        CGRect textRect = CGRectInset(self.bounds, kLayoutTextXInset, kLayoutTextYInset);
        albumRect.origin.y = floor(CGRectGetMidY(textRect) - (albumRect.size.height / 2.f));
        albumRect.size.width -= kLayoutTextXInset + durationRect.size.width;
        durationRect.origin.y = floor(CGRectGetMidY(textRect) - (durationRect.size.height / 2.f));
    }
    [_albumTextLayer setFrame:albumRect];
    [_artistTextLayer setFrame:artistRect];
    [_durationTextLayer setFrame:durationRect];
}

- (void)drawInContext:(CGContextRef)ctx
{
    drawGradientBackgroundInContext(ctx, [self bounds], self.tracking);
}

#pragma mark - CALayer Delegate

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale
   fromWindow:(NSWindow *)window
{
    return YES;
}
@end
