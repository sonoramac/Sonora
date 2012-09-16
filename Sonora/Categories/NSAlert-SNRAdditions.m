//
//  NSAlert-SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-28.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSAlert-SNRAdditions.h"
#import "NSError-SNRAdditions.h"

@implementation NSAlert (SNRAdditions)
+ (NSInteger)showErrorAlertWithDescription:(NSString*)desc
{
    NSError *error = [NSError genericErrorWithDescription:desc];
    NSAlert *alert = [NSAlert alertWithError:error];
    return [alert runModal];
}
@end
