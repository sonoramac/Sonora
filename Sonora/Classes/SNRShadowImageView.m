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

#import "SNRShadowImageView.h"

static NSString* const kImageClearButton = @"<SNRShadowImageView>clear";

@interface SNRShadowImageView ()
- (void)commonInitForSNRShadowImageView;
@end

@implementation SNRShadowImageView
@synthesize image = _image;
@synthesize shadow = _shadow;

#pragma mark - Initialization

- (id)initWithFrame:(NSRect)frameRect
{
    if ((self = [super initWithFrame:frameRect])) {
        [self commonInitForSNRShadowImageView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInitForSNRShadowImageView];
    }
    return self;
}

- (void)commonInitForSNRShadowImageView
{
    [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}

#pragma mark - Setters

- (void)setImage:(NSImage*)image
{
    if (_image != image) {
        _image = image;
        [self setNeedsDisplay:YES];
    }
}

#pragma mark - Drawing

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    NSRect drawingRect = self.bounds;
    if (self.shadow) {
        NSSize shadowOffset = self.shadow.shadowOffset;
        CGFloat blurRadius = self.shadow.shadowBlurRadius;
        drawingRect.origin.x += blurRadius - shadowOffset.width;
        drawingRect.size.width -= blurRadius * 2.f;
        drawingRect.origin.y += blurRadius - shadowOffset.height;
        drawingRect.size.height -= blurRadius * 2.f;
        [self.shadow set];
    }
    [self.image drawInRect:drawingRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.f];
}
@end
