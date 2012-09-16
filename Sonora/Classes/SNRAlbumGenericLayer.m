//
//  SNRAlbumGenericLayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-12.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
