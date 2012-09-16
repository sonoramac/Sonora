//
//  NSTableView-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-05.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

@interface NSTableView (SNRAdditions)
- (void)scrollRowToVisibleAnimated:(NSInteger)row;
- (NSIndexSet*)clickedAndSelectedRowIndexes;
@end