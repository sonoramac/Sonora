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

#import "SNRSaveMixImageView.h"
#import "NSShadow-SNRAdditions.h"

#define kPlaceholderTextFont [NSFont boldSystemFontOfSize:14.f]
#define kPlaceholderTextColor [NSColor colorWithDeviceWhite:0.62f alpha:1.f]
#define kPlaceholderTextXInset 50.f
#define kImageShadowOffset NSMakeSize(0.f, -1.f)
#define kImageShadowColor [NSColor blackColor]
#define kImageShadowBlurRadius 3.f

static NSString *const kImagePlaceholder = @"dotted-border";

@implementation SNRSaveMixImageView

- (void)drawRect:(NSRect)dirtyRect
{
    // Draw the placeholder
    if (!self.image) {
        NSImage *placeholder = [NSImage imageNamed:kImagePlaceholder];
        NSSize placeholderSize = [placeholder size];
        NSRect placeholderRect = NSMakeRect(floor(NSMidX([self bounds]) - (placeholderSize.width / 2.f)), floor(NSMidY([self bounds]) - (placeholderSize.height / 2.f)), placeholderSize.width, placeholderSize.height);
        [placeholder drawInRect:placeholderRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.f];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSCenterTextAlignment];
        NSShadow *textShadow = [NSShadow shadowWithOffset:NSMakeSize(0.f, -1.f) blurRadius:1.f color:[NSColor colorWithDeviceWhite:1.f alpha:0.5f]];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:textShadow, NSShadowAttributeName, style, NSParagraphStyleAttributeName, kPlaceholderTextFont, NSFontAttributeName, kPlaceholderTextColor, NSForegroundColorAttributeName, nil];
        NSAttributedString *placeholderText = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"DropMixArtwork", nil) attributes:attributes];
        NSSize textSize = [placeholderText size];
        NSRect textRect = NSMakeRect(kPlaceholderTextXInset, NSMidY([self bounds]) - (textSize.height / 2.f) , [self bounds].size.width - (kPlaceholderTextXInset * 2.f), textSize.height);
        [NSLocalizedString(@"DropMixArtwork", nil) drawInRect:textRect withAttributes:attributes];
    } else {
        NSSize shadowOffset = kImageShadowOffset;
        NSShadow *imageShadow = [NSShadow shadowWithOffset:shadowOffset blurRadius:kImageShadowBlurRadius color:kImageShadowColor];
        NSRect imageRect = NSMakeRect(kImageShadowBlurRadius - shadowOffset.width, kImageShadowBlurRadius - shadowOffset.height, [self bounds].size.width - (kImageShadowBlurRadius * 2.f), [self bounds].size.height - (kImageShadowBlurRadius * 2.f));
        [imageShadow set];
        [self.image drawInRect:imageRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.f];
    }
}

@end
