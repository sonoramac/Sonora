//
//  SNROutlineView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNROutlineView.h"
#import <Carbon/Carbon.h>

@implementation SNROutlineView
@dynamic delegate;

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent keyCode] == kVK_Delete) {
        NSIndexSet *selectedRows = [self selectedRowIndexes];
        if ([selectedRows count] && [[self delegate] respondsToSelector:@selector(outlineView:deleteRowsAtIndexes:)]) {
            [[self delegate] outlineView:self deleteRowsAtIndexes:selectedRows];
        }
    } else {
        [super keyDown:theEvent];
    }
}
@end
