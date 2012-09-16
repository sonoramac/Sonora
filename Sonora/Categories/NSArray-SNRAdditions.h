//
//  NSArray-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-10.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//


@interface NSArray (SNRAdditions)
- (NSArray*)randomizedArray;
@end

@interface NSMutableArray (SNRAdditions)
- (void)randomize;
- (void)moveObjectFromIndex:(NSUInteger)from to:(NSUInteger)to;
- (void)moveObjectsFromIndexes:(NSIndexSet*)from to:(NSUInteger)to;
@end