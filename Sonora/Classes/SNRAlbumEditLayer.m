//
//  SNRAlbumEditLayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-19.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRAlbumEditLayer.h"
#import "SNRAlbumDrawingHelpers.h"
#import "SNRGraphicsHelpers.h"

static NSString* const kImageNameEditMix = @"edit-mix";

@implementation SNRAlbumEditLayer {
    OEGridLayer *_imageLayer;
}
- (id)init
{
    if ((self = [super init])) {
        [self setMasksToBounds:YES];
        _imageLayer = [OEGridLayer layer];
        [_imageLayer setContents:[NSImage imageNamed:kImageNameEditMix]];
        [_imageLayer setContentsGravity:kCAGravityCenter];
        [self addSublayer:_imageLayer];
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    [_imageLayer setFrame:[self bounds]];
}

- (void)drawInContext:(CGContextRef)ctx
{
    drawGradientBackgroundInContext(ctx, [self bounds], self.tracking);
    
    // Draw the left divider and highlight
    CGColorRef highlight = CGColorCreateGenericGray(1.f, 0.1f);
    CGRect dividerRect = CGRectMake(1.f, 0.f, 1.f, self.bounds.size.height);
    CGContextSetFillColorWithColor(ctx, CGColorGetConstantColor(kCGColorBlack));
    CGContextFillRect(ctx, dividerRect);
    dividerRect.origin.x -= 1.f;
    CGContextSetFillColorWithColor(ctx, highlight);
    CGContextFillRect(ctx, dividerRect);
    CGColorRelease(highlight);
}
@end
