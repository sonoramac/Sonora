//
//  NSTableView-SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-05.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSTableView-SNRAdditions.h"
#import "NSView-SNRAdditions.h"

@implementation NSTableView (SNRAdditions)

- (void)scrollRowToVisibleAnimated:(NSInteger)row
{
    [self scrollPointAnimated:[self rectOfRow:row].origin];
}

- (NSIndexSet*)clickedAndSelectedRowIndexes
{
    NSInteger clicked = self.clickedRow;
    if (clicked != -1 && ![self.selectedRowIndexes containsIndex:clicked]) {
        return [NSIndexSet indexSetWithIndex:clicked];
    }
    return self.selectedRowIndexes;
}
@end
