//
//  NSGradient-SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-04.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSGradient-SNRAdditions.h"

@implementation NSGradient (SNRAdditions)
+ (id)gradientWithStartingColor:(NSColor*)startingColor endingColor:(NSColor*)endingColor
{
    return [[NSGradient alloc] initWithStartingColor:startingColor endingColor:endingColor];
}
@end
