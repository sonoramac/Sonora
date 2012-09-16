//
//  SNRAlbumButtonLayer.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-19.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRAlbumButtonLayer.h"

@implementation SNRAlbumButtonLayer
@synthesize mouseUpBlock = _mouseUpBlock;
- (id)init
{
    if ((self = [super init])) {
        self.opaque = NO;
        self.backgroundColor = CGColorGetConstantColor(kCGColorClear);
        self.needsDisplayOnBoundsChange = YES;
        self.interactive = YES;
    }
    return self;
}

#pragma mark - Mouse Events

- (void)mouseDownAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    self.tracking = YES;
    [self setNeedsDisplay];
}

- (void)mouseUpAtPointInLayer:(NSPoint)point withEvent:(NSEvent *)theEvent
{
    self.tracking = NO;
    [self setNeedsDisplay];
    if (self.mouseUpBlock) {
        self.mouseUpBlock(self);
    }
}
@end
