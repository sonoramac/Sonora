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
