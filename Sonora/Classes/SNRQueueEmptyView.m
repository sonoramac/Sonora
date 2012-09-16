//
//  SNRQueueEmptyView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-05-24.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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
