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

#import "SNRAlbumLabelLayer.h"
#import "SNRGraphicsHelpers.h"

#define kLayoutTextXInset 8.f
#define kLayoutTextYInset 4.f

@implementation SNRAlbumLabelLayer {
    CATextLayer *_textLayer;
}
@synthesize textLayer = _textLayer;

- (id)init
{
    if ((self = [super init])) {
        self.opaque = NO;
        self.backgroundColor = CGColorGetConstantColor(kCGColorClear);
        self.needsDisplayOnBoundsChange = YES;
        _textLayer = [CATextLayer layer];
        _textLayer.font = (__bridge CFTypeRef)[NSFont boldSystemFontOfSize:11.f];
        _textLayer.fontSize = 11.f;
        _textLayer.shadowColor = CGColorGetConstantColor(kCGColorBlack);
        _textLayer.shadowRadius = 1.f;
        _textLayer.shadowOpacity = 0.3f;
        _textLayer.shadowOffset = CGSizeMake(0.f, 1.f);
        _textLayer.contentsScale = SONORA_SCALE_FACTOR;
        _textLayer.delegate = self;
        [self addSublayer:_textLayer];
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    _textLayer.frame = CGRectInset([self bounds], kLayoutTextXInset, kLayoutTextYInset);
}

- (CGSize)preferredFrameSize
{
    CGSize textSize = _textLayer.preferredFrameSize;
    textSize.height += kLayoutTextYInset * 2.f;
    textSize.width += kLayoutTextXInset * 2.f;
    return textSize;
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGFloat cornerRadius = floor([self bounds].size.height / 2.f);
    SNRCGContextAddRoundedRect(ctx, [self bounds], cornerRadius);
    CGColorRef fillColor = CGColorCreateGenericGray(0.f, 0.5f);
    CGContextSetFillColorWithColor(ctx, fillColor);
    CGContextFillPath(ctx);
    CGColorRelease(fillColor);
}

#pragma mark - CALayer Delegate

- (BOOL)layer:(CALayer *)layer shouldInheritContentsScale:(CGFloat)newScale
   fromWindow:(NSWindow *)window
{
    return YES;
}
@end
