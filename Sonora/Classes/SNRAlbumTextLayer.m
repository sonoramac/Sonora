//
//  SNRAlbumTextLayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
