//
//  NSWindow+SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-10-31.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSWindow+SNRAdditions.h"

#define kWindowAnimationDuration 0.1f

@implementation NSWindow (SNRAdditions)
- (BOOL)isFullscreen
{
    return ([self styleMask] & NSFullScreenWindowMask) == NSFullScreenWindowMask;
}

- (BOOL)drawAsActive
{
    return ([self isMainWindow] && [NSApp isActive]) || [self isFullscreen];
}

- (IBAction)fadeIn:(id)sender
{
    [self setAlphaValue:0.f];
    [self makeKeyAndOrderFront:nil];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:kWindowAnimationDuration];
    [[self animator] setAlphaValue:1.f];
    [NSAnimationContext endGrouping];
}

- (IBAction)fadeOut:(id)sender
{
    [NSAnimationContext beginGrouping];
    __block NSWindow *bself = self;
    [[NSAnimationContext currentContext] setDuration:kWindowAnimationDuration];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [bself orderOut:nil];
        [bself setAlphaValue:1.f];
    }];
    [[self animator] setAlphaValue:0.f];
    [NSAnimationContext endGrouping];
}

- (void)endEditingPreservingFirstResponder:(BOOL)preserve
{
    if (preserve) {
        id oldFirstResponder = [self firstResponder];
        if (oldFirstResponder && [oldFirstResponder isKindOfClass:[NSTextView class]] && [(NSTextView*)oldFirstResponder isFieldEditor]) {
            oldFirstResponder = [oldFirstResponder delegate];
            if ([oldFirstResponder isKindOfClass:[NSResponder class]] == NO) {
                oldFirstResponder = nil;
            }
        } 
        if (![self makeFirstResponder:self]) {
            [self endEditingFor:nil];
        }
        if (oldFirstResponder) {
            [self makeFirstResponder:oldFirstResponder];
        }
    } else {
        [self makeFirstResponder:self];
    }
}
@end
