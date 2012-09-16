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

#import "SNRSearchTableCellView.h"
#import "SNRShadowImageView.h"

#import "NSShadow-SNRAdditions.h"

#define kArtworkShadowOffset NSMakeSize(0.f, -1.f)
#define kArtworkShadowBlurRadius 3.f
#define kArtworkShadowColor [NSColor colorWithDeviceWhite:0.f alpha:0.75f]
#define kSeparatorColor [NSColor colorWithDeviceWhite:0.90f alpha:1.f]
#define kLayoutPlusButtonWidth 46.f

#define kSelectionBackgroundColor [NSColor colorWithDeviceRed:0.0f green:0.271f blue:0.604f alpha:0.14f]

@implementation SNRSearchTableCellView
@synthesize subtitleTextField = _subtitleTextField;
@synthesize statisticTextField = _statisticTextField;
@synthesize iconImageView = _iconImageView;
@synthesize artworkImageView = _artworkImageView;
@synthesize enqueueButton = _enqueueButton;

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Manually configure the artwork view because it's custom
    [self.artworkImageView bind:@"image" toObject:self withKeyPath:@"objectValue.searchArtwork" options:nil];
    self.artworkImageView.shadow = [NSShadow shadowWithOffset:kArtworkShadowOffset blurRadius:kArtworkShadowBlurRadius color:kArtworkShadowColor];
}
@end

@implementation SNRSearchTableRowView

- (BOOL)isEmphasized
{
    return YES;
}

- (void)drawBackgroundInRect:(NSRect)dirtyRect
{
    [super drawBackgroundInRect:dirtyRect];
    NSRect separatorRect = NSMakeRect(0.f, NSMaxY([self bounds]) - 1.f, [self bounds].size.width, 1.f);
    [kSeparatorColor set];
    NSRectFill(separatorRect);
    NSRect plusSeparator = NSMakeRect(NSMaxX([self bounds]) - kLayoutPlusButtonWidth, 0.f, 1.f, [self bounds].size.height);
    NSRectFill(plusSeparator);
}

@end

