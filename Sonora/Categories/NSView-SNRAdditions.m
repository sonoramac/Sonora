/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
