//
//  SNRAlbumDropLayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-15.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRAlbumDropLayer.h"
#import "SNRAlbumLabelLayer.h"

#define kLayoutTextBottomInset 10.f

@implementation SNRAlbumDropLayer {
    SNRAlbumLabelLayer *_labelLayer;
}
    
- (id)init
{
    if ((self = [super init])) {
        _labelLayer = [SNRAlbumLabelLayer layer];
        _labelLayer.textLayer.string = NSLocalizedString(@"SetArtwork", nil);
        [self addSublayer:_labelLayer];
    }
    return self;
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    CGRect labelFrame = CGRectZero;
    labelFrame.size = _labelLayer.preferredFrameSize;
    labelFrame.origin = CGPointMake(CGRectGetMidY([self bounds]) - (labelFrame.size.width / 2.f), CGRectGetMaxY([self bounds]) - (labelFrame.size.height + kLayoutTextBottomInset));
    _labelLayer.frame = labelFrame;
}

@end
