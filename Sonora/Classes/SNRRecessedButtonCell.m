//
//  SNRRecessedButtonCell.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-25.
//  Copyright 2011 PCWiz Computer. All rights reserved.
//

#import "SNRRecessedButtonCell.h"
#import "NSBezierPath+MCAdditions.h"

#define kShadowBlurRadius 1.f
#define kShadowColor [NSColor colorWithDeviceWhite:0.f alpha:0.5f]
#define kTextShadowColor [NSColor colorWithDeviceWhite:1.f alpha:0.75f]

#define kNormalColor [NSColor colorWithDeviceRed:0.525 green:0.525 blue:0.525 alpha:1.00]
#define kLayoutLeftInset 3.f

@implementation SNRRecessedButtonCell

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self.image setTemplate:YES];
        [self.alternateImage setTemplate:YES];
    }
    return self;
}

- (NSRect)drawTitle:(NSAttributedString *)title withFrame:(NSRect)frame inView:(NSView *)controlView
{
    NSDictionary *attributes = nil;
    if ([title length]) {
        attributes = [title attributesAtIndex:0 effectiveRange:NULL];
    }
    NSColor *defaultColor = [attributes valueForKey:NSForegroundColorAttributeName];
    BOOL mouseOver = [defaultColor isEqual:[NSColor whiteColor]];
    NSColor *color = (mouseOver) ? defaultColor : kNormalColor;
    NSFont *font = [attributes valueForKey:NSFontAttributeName];
    if (!font) {
        font = [NSFont systemFontOfSize:[NSFont systemFontSize]];
    }
    NSSize titleSize = title.size;
    NSRect titleRect = NSMakeRect(frame.origin.x, NSMidY(frame) - (titleSize.height / 2.f), titleSize.width, titleSize.height);
    titleRect.origin.y -= 1.f; // Adjust it a bit to vertically center properly
    NSBezierPath *original = [[title string] bezierWithFont:font];
    NSBezierPath *bezierPath = [original copy];
    NSAffineTransform *transform = [NSAffineTransform transform];
    [transform translateXBy:kLayoutLeftInset yBy:0.f];
    [bezierPath transformUsingAffineTransform:transform];
    if (!mouseOver) {
        NSBezierPath *shadowPath = [original copy];
        NSAffineTransform *shadowTransform = [NSAffineTransform transform];
        [shadowTransform translateXBy:kLayoutLeftInset yBy:1.f];
        [shadowPath transformUsingAffineTransform:shadowTransform];
        [kTextShadowColor set];
        [shadowPath fill];
    }
    [color set];
    [bezierPath fill];
    if (!mouseOver) {
        NSShadow *shadow = [NSShadow shadowWithOffset:NSZeroSize blurRadius:kShadowBlurRadius color:kShadowColor];
        [bezierPath fillWithInnerShadow:shadow];
    }
    return titleRect;
}
@end