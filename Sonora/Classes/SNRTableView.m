//
//  SNRTableView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRTableView.h"
#import <Carbon/Carbon.h>

@implementation SNRTableView
@dynamic delegate;

- (void)keyDown:(NSEvent *)theEvent
{
    if ([theEvent keyCode] == kVK_Delete) {
        NSIndexSet *selectedRows = [self selectedRowIndexes];
        if ([selectedRows count] && [self.delegate respondsToSelector:@selector(tableView:deleteRowsAtIndexes:)]) {
            [[self delegate] tableView:self deleteRowsAtIndexes:selectedRows];
        }
    } else {
        [super keyDown:theEvent];
    }
}

- (NSDragOperation)tableView:(NSTableView*)tableView draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    if ([self.delegate respondsToSelector:@selector(tableView:draggingSession:sourceOperationMaskForDraggingContext:)]) {
        return [self.delegate tableView:self draggingSession:session sourceOperationMaskForDraggingContext:context];
    } else {
        return NSDragOperationGeneric;
    }
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
    if ([self.delegate respondsToSelector:@selector(tableView:draggingSession:sourceOperationMaskForDraggingContext:)]) {
        return [self.delegate tableView:self draggingSession:nil sourceOperationMaskForDraggingContext:0];
    } else {
        return NSDragOperationGeneric;
    }
}

@end
