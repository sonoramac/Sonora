//
//  NSShadow-SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-04.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSShadow-SNRAdditions.h"

@implementation NSShadow (SNRAdditions)
+ (NSShadow*)shadowWithOffset:(NSSize)offset blurRadius:(CGFloat)radius color:(NSColor*)color
{
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowOffset:offset];
    [shadow setShadowBlurRadius:radius];
    [shadow setShadowColor:color];
    return shadow;
}
@end
