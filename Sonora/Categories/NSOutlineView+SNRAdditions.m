//
//  NSOutlineView+SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSOutlineView+SNRAdditions.h"

@implementation NSOutlineView (SNRAdditions)
- (NSArray*)itemsAtRowIndexes:(NSIndexSet*)rowIndexes
{
    NSMutableArray *items = [NSMutableArray arrayWithCapacity:[rowIndexes count]];
    [rowIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [items addObject:[self itemAtRow:idx]];
    }];
    return items;
}
@end
