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

#import "SNRQueueEmptyView.h"

#import "NSShadow-SNRAdditions.h"

#define kTextShadowColor [NSColor colorWithDeviceWhite:1.f alpha:0.5f]
#define kTextShadowBlurRadius 1.f
#define kTextShadowOffset NSMakeSize(0.f, -1.f)
#define kTextColor [NSColor colorWithDeviceWhite:0.49f alpha:1.f]
#define kTextFont [NSFont systemFontOfSize:20.f]

@implementation SNRQueueEmptyView

- (void)drawRect:(NSRect)dirtyRect
{
    CGContextSetShouldSmoothFonts([[NSGraphicsContext currentContext] graphicsPort], false);
    NSShadow *textShadow = [NSShadow shadowWithOffset:kTextShadowOffset blurRadius:kTextShadowBlurRadius color:kTextShadowColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:textShadow, NSShadowAttributeName, kTextColor, NSForegroundColorAttributeName, kTextFont, NSFontAttributeName, nil];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"QueueEmpty", nil) attributes:attributes];
    NSSize stringSize = [string size];
    NSRect stringRect = NSMakeRect(NSMidX([self bounds]) - (stringSize.width / 2.f), NSMidY([self bounds]) - (stringSize.height / 2.f), stringSize.width, stringSize.height);
    [string drawInRect:NSIntegralRect(stringRect)];
}

@end
