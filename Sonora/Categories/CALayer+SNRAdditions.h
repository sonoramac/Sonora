//
//  CALayer+SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (SNRAdditions)
- (void)animateFromFrame:(CGRect)frame toFrame:(CGRect)newFrame duration:(NSTimeInterval)duration timingFunction:(CAMediaTimingFunction*)timingFunction;
- (void)animateOpacityFrom:(CGFloat)opacity toOpacity:(CGFloat)newOpacity duration:(NSTimeInterval)duration timingFunction:(CAMediaTimingFunction*)timingFunction;
- (NSImage*)NSImage;
@end
