//
//  SNRSearchIndex-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-29.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRSearchIndex.h"

@interface SNRSearchIndex (SNRAdditions)
- (BOOL)updateSearchIndexForSonoraObject:(NSManagedObject*)object;
@end
