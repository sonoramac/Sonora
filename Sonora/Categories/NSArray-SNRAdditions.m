//
//  NSArray-SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-10.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSArray-SNRAdditions.h"

@implementation NSArray (SNRAdditions)
- (NSArray*)randomizedArray
{
    NSMutableArray *array = [NSMutableArray arrayWithArray:self];
    [array randomize];
    return [NSArray arrayWithArray:array];
}
@end

@implementation NSMutableArray (SNRAdditions)
- (void)randomize
{
    NSUInteger count = [self count];
    for (NSUInteger i = 0; i < count; ++i) {
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [self exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (void)moveObjectFromIndex:(NSUInteger)from to:(NSUInteger)to
{
    if (to != from) {
        id obj = [self objectAtIndex:from];
        [self removeObjectAtIndex:from];
        NSUInteger newIndex = (to > from) ? to - 1 : to;
        if (newIndex >= [self count]) {
            [self addObject:obj];
        } else {
            [self insertObject:obj atIndex:newIndex];
        }
    }
}

- (void)moveObjectsFromIndexes:(NSIndexSet*)from to:(NSUInteger)to
{
    NSUInteger first = [from firstIndex];
    NSArray *objects = [self objectsAtIndexes:from];
    [self removeObjectsAtIndexes:from];
    NSUInteger newIndex = (to > first) ? to - [objects count] : to;
    if (newIndex >= [self count]) {
        [self addObjectsFromArray:objects];
    } else {
        NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(newIndex, [objects count])];
        [self insertObjects:objects atIndexes:indexes];
    }
}
@end