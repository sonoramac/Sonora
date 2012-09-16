//
//  NSShadow-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-04.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

@interface NSShadow (SNRAdditions)
+ (NSShadow*)shadowWithOffset:(NSSize)offset blurRadius:(CGFloat)radius color:(NSColor*)color;
@end
