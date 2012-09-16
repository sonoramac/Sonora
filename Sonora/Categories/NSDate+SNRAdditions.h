//
//  NSDate+SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-16.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (SNRAdditions)
- (NSDate*)dateByAddingDays:(NSInteger)days;
+ (NSInteger)daysUntilDate:(NSDate*)date;
@end
