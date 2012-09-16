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

#import "SNRSharedImageCache.h"

#define kNoiseImageWidth 128
#define kNoiseImageHeight 128
#define kNoiseImageFactor 0.015

@implementation SNRSharedImageCache
@synthesize noiseImage = _noiseImage;

+ (SNRSharedImageCache *)sharedInstance 
{
    static SNRSharedImageCache *manager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (CGImageRef)noiseImage
{
    if (!_noiseImage) {
        int size = kNoiseImageWidth * kNoiseImageHeight;
        char *rgba = (char *)malloc(size); srand(124);
        for(int i=0; i < size; ++i){rgba[i] = rand()%256*kNoiseImageFactor;}
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGContextRef bitmapContext = 
        CGBitmapContextCreate(rgba, kNoiseImageWidth, kNoiseImageHeight, 8, kNoiseImageWidth, colorSpace, kCGImageAlphaNone);
        CFRelease(colorSpace);
        free(rgba);
        _noiseImage = CGBitmapContextCreateImage(bitmapContext);
        CFRelease(bitmapContext);
    }
    return _noiseImage;
}

- (void)drawNoiseImage
{
    [NSGraphicsContext saveGraphicsState];
    [[NSGraphicsContext currentContext] setCompositingOperation:NSCompositePlusLighter];
    CGRect noisePatternRect = CGRectZero;
    CGImageRef noise = [self noiseImage];
    noisePatternRect.size = CGSizeMake(CGImageGetWidth(noise), CGImageGetHeight(noise));        
    CGContextRef context = [[NSGraphicsContext currentContext] graphicsPort];
    CGContextDrawTiledImage(context, noisePatternRect, noise);
    [NSGraphicsContext restoreGraphicsState];

}

@end
