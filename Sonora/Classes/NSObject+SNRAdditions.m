//
//  NSObject+SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSObject+SNRAdditions.h"

@implementation NSObject (SNRAdditions)
- (void)performBlock:(void (^)(void))block 
          afterDelay:(NSTimeInterval)delay 
{
    block = [block copy];
    [self performSelector:@selector(fireBlockAfterDelay:) 
               withObject:block 
               afterDelay:delay];
}

- (void)fireBlockAfterDelay:(void (^)(void))block {
    block();
}
@end
