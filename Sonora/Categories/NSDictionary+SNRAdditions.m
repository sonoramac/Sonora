//
//  NSDictionary+SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-04.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSDictionary+SNRAdditions.h"

@implementation NSDictionary (SNRAdditions)
- (id)nilOrValueForKey:(NSString*)key
{
    id value = [self valueForKey:key];
    return (value == [NSNull null]) ? nil : value;
}
@end
