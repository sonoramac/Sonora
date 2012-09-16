//
//  SNRQueueScroller.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-04-14.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRQueueScroller.h"

@implementation SNRQueueScroller

+ (BOOL)isCompatibleWithOverlayScrollers { return YES; }
- (void)drawKnob {}
- (void)drawKnobSlotInRect:(NSRect)slotRect highlight:(BOOL)flag {}
+ (CGFloat)scrollerWidthForControlSize:(NSControlSize)controlSize scrollerStyle:(NSScrollerStyle)scrollerStyle { return 0.0; }
+ (CGFloat)scrollerWidth { return 0.0; }
+ (CGFloat)scrollerWidthForControlSize:(NSControlSize)controlSize { return 0.0; }

@end
