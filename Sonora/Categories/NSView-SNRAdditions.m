//
//  NSView-SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-09-08.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSView-SNRAdditions.h"

@implementation NSView (SNRAdditions)
- (void)scrollPointAnimated:(NSPoint)point
{
    [self scrollPointAnimated:point completionBlock:nil];
}

- (void)scrollPointAnimated:(NSPoint)point completionBlock:(void (^)())block
{
    NSScrollView *scrollView = [self enclosingScrollView];
    NSClipView *clipView = [scrollView contentView];
    NSPoint constrainedPoint = [clipView constrainScrollPoint:point];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[NSAnimationContext currentContext] setCompletionHandler:block];
    [[clipView animator] setBoundsOrigin:constrainedPoint];
    [NSAnimationContext endGrouping];
    [scrollView reflectScrolledClipView:clipView];
}

- (NSImage*)NSImage
{
    NSSize viewSize = [self bounds].size;
    NSBitmapImageRep *bir = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
    [bir setSize:viewSize];
    [self cacheDisplayInRect:[self bounds] toBitmapImageRep:bir];
    NSImage* image = [[NSImage alloc] initWithSize:viewSize];
    [image addRepresentation:bir];
    return image;
}

- (void)pushToView:(NSView*)view direction:(SNRViewAnimationDirection)direction
{
    if (![self superview]) { return; }
    BOOL left = (direction == SNRViewAnimationDirectionLeft);
    NSRect firstViewFinalFrame = [self frame];
    firstViewFinalFrame.origin.x = -firstViewFinalFrame.size.width;
    NSRect secondViewStartingFrame = [view frame];
    secondViewStartingFrame.size = firstViewFinalFrame.size;
    secondViewStartingFrame.origin.y = firstViewFinalFrame.origin.y;
    secondViewStartingFrame.origin.x = NSMaxX([self frame]);
    [view setFrame:left ? secondViewStartingFrame : firstViewFinalFrame];
    [[self superview] addSubview:view];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [self removeFromSuperview];
    }];
    [[view animator] setFrame:[self frame]];
    [[self animator] setFrame:left ? firstViewFinalFrame : secondViewStartingFrame];
    [NSAnimationContext endGrouping];
}
@end
