//
//  NSMenu+SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-10.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSMenu+SNRAdditions.h"

@implementation NSMenu (SNRAdditions)
- (void)popupFromView:(NSView*)view
{
    NSPoint localPoint = NSMakePoint(NSMidX([view bounds]), NSMidY([view bounds]));
    NSPoint windowPoint = [view convertPoint:localPoint toView:nil];
    NSEvent *fakeEvent = [NSEvent mouseEventWithType:NSLeftMouseDown location:windowPoint modifierFlags:0 timestamp:0 windowNumber:[[view window] windowNumber] context:[[view window] graphicsContext] eventNumber:0 clickCount:1 pressure:1];
    [NSMenu popUpContextMenu:self withEvent:fakeEvent forView:view];
}
@end
