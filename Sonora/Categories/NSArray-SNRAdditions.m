/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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