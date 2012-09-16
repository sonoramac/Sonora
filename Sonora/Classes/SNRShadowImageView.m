//
//  SNRShadowImageView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-09.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

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
