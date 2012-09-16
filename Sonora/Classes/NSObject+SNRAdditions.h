//
//  NSObject+SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (SNRAdditions)
- (void)performBlock:(void (^)(void))block afterDelay:(NSTimeInterval)delay;
@end
