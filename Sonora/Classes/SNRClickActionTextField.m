//
//  SNRClickActionTextField.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-31.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRClickActionTextField.h"

@implementation SNRClickActionTextField
@synthesize mouseUpBlock = _mouseUpBlock;

- (void)resetCursorRects
{
    [self addCursorRect:[self bounds] cursor:[NSCursor pointingHandCursor]];
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (self.mouseUpBlock) {
        self.mouseUpBlock();
    }
}
@end
