//
//  NSDictionary+SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-04.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (SNRAdditions)
- (id)nilOrValueForKey:(NSString*)key;
@end
