//
//  SNRPopoverButtonCell.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-09.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRPopoverButtonCell.h"

#import "NSShadow-SNRAdditions.h"

#define kBackgroundGradientStartingColor [NSColor colorWithDeviceWhite:0.94f alpha:1.f]
#define kBackgroundGradientEndingColor [NSColor colorWithDeviceWhite:0.99f alpha:1.f]
#define kBorderColor [NSColor colorWithDeviceWhite:0.69f alpha:1.f]
#define kBorderCornerRadius 3.f
#define kTextColor [NSColor colorWithDeviceWhite:0.4f alpha:1.f]
#define kTextFont [NSFont systemFontOfSize:11.f]
#define kTextShadowBlurRadius 1.f
#define kTextShadowOffset NSMakeSize(0.f, 1.f)
#define kTextShadowColor [NSColor colorWithDeviceWhite:1.f alpha:0.75f]
#define kHighlightedOverlayColor [NSColor colorWithDeviceWhite:0.f alpha:0.3f]

@implementation SNRPopoverButtonCell

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    NSRect drawingRect = NSInsetRect(cellFrame, 0.5f, 0.5f);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:drawingRect xRadius:kBorderCornerRadius yRadius:kBorderCornerRadius];
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:kBackgroundGradientStartingColor endingColor:kBackgroundGradientEndingColor];
    [gradient drawInBezierPath:path angle:270.f];
    [kBorderColor set];
    [path stroke];
    NSShadow *shadow = [NSShadow shadowWithOffset:kTextShadowOffset blurRadius:kTextShadowBlurRadius color:kTextShadowColor];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:NSCenterTextAlignment];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:kTextColor, NSForegroundColorAttributeName, kTextFont, NSFontAttributeName, shadow, NSShadowAttributeName, style, NSParagraphStyleAttributeName, nil];
    NSAttributedString *title = [[NSAttributedString alloc] initWithString:[self title] attributes:attributes];
    NSSize titleSize = [title size];
    NSRect textRect = NSMakeRect(0.f, NSMidY(cellFrame) - (titleSize.height / 2.f), cellFrame.size.width, titleSize.height);
    [title drawInRect:textRect];
    if ([self isHighlighted]) {
        [kHighlightedOverlayColor set];
        [path fill];
    }
}

@end
