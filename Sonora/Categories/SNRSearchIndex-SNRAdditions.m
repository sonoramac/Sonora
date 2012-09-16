//
//  SNRSearchIndex-SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-29.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRSearchIndex-SNRAdditions.h"
#import "NSString-SNRAdditions.h"

@implementation SNRSearchIndex (SNRAdditions)
- (BOOL)updateSearchIndexForSonoraObject:(NSManagedObject*)object
{
    NSString *name = [object valueForKey:@"name"];
    NSManagedObjectID *identifier = [object objectID];
    if ([identifier isTemporaryID]) {
        if (![object.managedObjectContext obtainPermanentIDsForObjects:[NSArray arrayWithObject:object] error:nil]) {
            return NO;
        }
        identifier = [object objectID];
    }
    [self setKeywords:[name spaceSeparatedComponents] forObjectID:identifier];
    return YES;
}
@end
