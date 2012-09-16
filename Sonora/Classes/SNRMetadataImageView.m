//
//  SNRMetadataImageView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-03.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRMetadataImageView.h"

#import "NSBezierPath+MCAdditions.h"
#import "NSShadow-SNRAdditions.h"

#define kBackgroundColor [NSColor colorWithDeviceWhite:0.000 alpha:0.150]
#define kBorderColor [NSColor blackColor]
#define kDropShadowColor [NSColor colorWithDeviceWhite:1.000 alpha:0.100]
#define kInnerShadowColor [NSColor blackColor]
#define kInnerShadowOffset NSMakeSize(0.f, 0.f)
#define kInnerShadowBlurRadius 5.f

#define kTextColor [NSColor colorWithDeviceWhite:0.23f alpha:1.f]
#define kTextFont [NSFont boldSystemFontOfSize:13.f]
#define kTextShadowBlurRadius 1.f
#define kTextShadowColor [NSColor blackColor]
#define kTextShadowOffset NSMakeSize(0.f, 1.f)

@implementation SNRMetadataImageView
@synthesize placeholder = _placeholder;

- (void)drawRect:(NSRect)dirtyRect
{
    NSRect drawingRect = NSInsetRect(self.bounds, 1.f, 1.f); // Inset 1px on all sides for border
    drawingRect.origin.y += 1.f; // Make space for the highlight line
    drawingRect.size.height -= 1.f; 
    if (self.image) {
        [[NSColor blackColor] set];
        NSRectFill(drawingRect);
        [self.image drawInRect:drawingRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.f];
    }
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:drawingRect];
    [kBackgroundColor set];
    [path fill];
    [kBorderColor set];
    [path stroke];
    NSShadow *shadow = [NSShadow shadowWithOffset:kInnerShadowOffset blurRadius:kInnerShadowBlurRadius color:kInnerShadowColor];
    [path fillWithInnerShadow:shadow];
    NSRect dropShadowRect = NSMakeRect(drawingRect.origin.x, 0.f, drawingRect.size.width, 1.f);
    [kDropShadowColor set];
    [NSBezierPath fillRect:dropShadowRect];
    if (!self.image && self.placeholder) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        [style setAlignment:NSCenterTextAlignment];
        NSShadow *shadow = [NSShadow shadowWithOffset:kTextShadowOffset blurRadius:kTextShadowBlurRadius color:kTextShadowColor];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:style, NSParagraphStyleAttributeName, shadow, NSShadowAttributeName, kTextColor, NSForegroundColorAttributeName, kTextFont, NSFontAttributeName, nil];
        NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:self.placeholder attributes:attributes];
        NSSize placeholderSize = placeholder.size;
        NSRect placeholderRect = NSMakeRect(0.f, NSMidY(self.bounds) - (placeholderSize.height / 2.f), self.bounds.size.width, placeholderSize.height);
        [placeholder drawInRect:placeholderRect];
    }
}

- (void)setPlaceholder:(NSString *)placeholder
{
    if (_placeholder != placeholder) {
        _placeholder = placeholder;
        [self setNeedsDisplay:YES];
    }
}
@end
