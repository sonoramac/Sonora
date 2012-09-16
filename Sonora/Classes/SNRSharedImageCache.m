//
//  SNRSharedImageCache.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-21.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
