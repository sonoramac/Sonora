//
//  NSDate+SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-16.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSDate+SNRAdditions.h"

@implementation NSDate (SNRAdditions)
- (NSDate*)dateByAddingDays:(NSInteger)days
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:days];
    return [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
}

+ (NSInteger)daysUntilDate:(NSDate*)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit fromDate:[NSDate date] toDate:date options:0];
    return [components day];
}
@end
