//
//  SNRHUDTooltipWindow.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRHUDTooltipWindow.h"

#import "NSObject+SNRAdditions.h"
#import "NSShadow-SNRAdditions.h"

#define kTextColor [NSColor whiteColor]
#define kTextFont [NSFont boldSystemFontOfSize:11.f]
#define kTextShadowBlurRadius 1.f
#define kTextShadowColor [NSColor colorWithDeviceWhite:0.f alpha:0.3f]
#define kTextShadowOffset NSMakeSize(0.f, -1.f)
#define kTextXInset 8.f
#define kTextYInset 4.f
#define kAnimationPauseDuration 0.25f
#define kAnimationDuration 0.5f
#define kAnimationOffset 10.f
#define kBackgroundFillColor [NSColor colorWithDeviceWhite:0.f alpha:0.5f]

@interface SNRHUDTooltipWindowContentView : NSView
@end

@interface SNRHUDTooltipWindow ()
- (NSSize)snr_windowSize;
@end

@implementation SNRHUDTooltipWindow
- (id)initWithTitle:(NSString*)title
{
    if ((self = [super initWithContentRect:NSZeroRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO])) {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setTitle:title];
        NSSize size = [self snr_windowSize];
        NSRect frame = NSMakeRect(0.f, 0.f, size.width, size.height);
        [self setFrame:frame display:NO];
        [self setContentView:[[SNRHUDTooltipWindowContentView alloc] initWithFrame:frame]];
    }
    return self;
}

- (void)setTitle:(NSString *)aString
{
    [super setTitle:aString];
    [[self contentView] setNeedsDisplay:YES];
}

- (NSSize)snr_windowSize
{
    NSShadow *shadow = [NSShadow shadowWithOffset:kTextShadowOffset blurRadius:kTextShadowBlurRadius color:kTextShadowColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:kTextColor, NSForegroundColorAttributeName, kTextFont, NSFontAttributeName, shadow, NSShadowAttributeName, nil];
    NSSize titleSize = [[self title] sizeWithAttributes:attributes];
    return NSMakeSize(titleSize.width + (kTextXInset * 2.f), titleSize.height + (kTextYInset * 2.f));
}

- (void)flashAtPoint:(NSPoint)screenPoint
{
    NSRect newFrame = [self frame];
    newFrame.origin.x = screenPoint.x + kTextXInset;
    newFrame.origin.y = round(screenPoint.y - (newFrame.size.height / 2.f));
    [self setFrame:newFrame display:YES];
    newFrame.origin.x += kAnimationOffset;
    [self makeKeyAndOrderFront:nil];
    __block NSWindow *blockSelf = self;
    [self performBlock:^{
        [NSAnimationContext beginGrouping];
        [[NSAnimationContext currentContext] setDuration:kAnimationDuration];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [blockSelf orderOut:nil];
            [blockSelf setAlphaValue:1.f];
        }];
        [[blockSelf animator] setFrame:newFrame display:YES];
        [[blockSelf animator] setAlphaValue:0.f];
        [NSAnimationContext endGrouping];
    } afterDelay:kAnimationPauseDuration];
}
@end


@implementation SNRHUDTooltipWindowContentView

- (void)drawRect:(NSRect)dirtyRect
{
    CGFloat cornerRadius = floor([self bounds].size.height / 2.f);
    NSBezierPath *path = [NSBezierPath bezierPathWithRoundedRect:[self bounds] xRadius:cornerRadius yRadius:cornerRadius];
    [kBackgroundFillColor set];
    [path fill];
    NSShadow *shadow = [NSShadow shadowWithOffset:kTextShadowOffset blurRadius:kTextShadowBlurRadius color:kTextShadowColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:kTextColor, NSForegroundColorAttributeName, kTextFont, NSFontAttributeName, shadow, NSShadowAttributeName, nil];
    NSAttributedString *attrTitle = [[NSAttributedString alloc] initWithString:[[self window] title] attributes:attributes];
    NSRect textRect = NSInsetRect([self bounds], kTextXInset, kTextYInset);
    [attrTitle drawInRect:textRect];
}
@end