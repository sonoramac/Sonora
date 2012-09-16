//
//  SNRAlbumLabelLayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-15.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
