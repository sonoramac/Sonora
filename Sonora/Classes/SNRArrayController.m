//
//  SNRArrayController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-15.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArrayController.h"

@implementation SNRArrayController
@synthesize fetchSortDescriptors = _fetchSortDescriptors;
- (BOOL)fetchWithRequest:(NSFetchRequest *)fetchRequest merge:(BOOL)merge error:(NSError **)error
{
    [fetchRequest setFetchBatchSize:20];
    [fetchRequest setSortDescriptors:self.fetchSortDescriptors];
    return [super fetchWithRequest:fetchRequest merge:merge error:error];
    
}
@end
