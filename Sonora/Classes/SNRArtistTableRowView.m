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

#import "SNRArtistTableRowView.h"

#define kBackgroundColor [NSColor colorWithDeviceWhite:0.95f alpha:1.f]
#define kSeparatorColor [NSColor colorWithDeviceWhite:0.90f alpha:1.f]
#define kTopHighlightColor [NSColor colorWithDeviceWhite:1.f alpha:0.6f]
#define kRightHighlightColor [NSColor colorWithDeviceWhite:1.f alpha:0.75f]

@implementation SNRArtistTableRowView
@synthesize hideSeparator = _hideSeparator;

- (BOOL)isEmphasized
{
    return YES;
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    [kBackgroundColor set];
    NSRectFill([self bounds]);
    NSRect topHighlightRect = NSMakeRect(0.f, 0.f, [self bounds].size.width, 1.f);
    [kTopHighlightColor set];
    [NSBezierPath fillRect:topHighlightRect];
    NSRect rightHighlightRect = NSMakeRect(NSMaxX([self bounds]) - 1.f, 0.f, 1.f, [self bounds].size.height);
    [kRightHighlightColor set];
    [NSBezierPath fillRect:rightHighlightRect];
    if (!self.hideSeparator) {
        NSRect separatorRect = topHighlightRect;
        separatorRect.origin.y = NSMaxY([self bounds]) - 1.f;
        [kSeparatorColor set];
        NSRectFill(separatorRect);
    }
}

- (NSTableViewSelectionHighlightStyle)selectionHighlightStyle
{
    return NSTableViewSelectionHighlightStyleSourceList;
}
@end
