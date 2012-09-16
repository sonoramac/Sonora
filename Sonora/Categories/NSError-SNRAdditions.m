//
//  NSError-SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-28.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSError-SNRAdditions.h"

static NSString* const kDefaultErrorDomain = @"SonoraApplicationError";
#define kDefaultErrorCode 0

@implementation NSError (SNRAdditions)
+ (NSError*)errorWithCode:(NSInteger)code description:(NSString*)desc
{
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:desc, NSLocalizedDescriptionKey, nil];
    return [NSError errorWithDomain:kDefaultErrorDomain code:code userInfo:userInfo];
}

+ (NSError*)genericErrorWithDescription:(NSString*)desc
{
    return [self errorWithCode:kDefaultErrorCode description:desc];
}
@end
