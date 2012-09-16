//
//  SNRVerticallyCenteredTextField.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-07.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRVerticallyCenteredTextField.h"

@interface SNRVerticallyCenteredTextFieldCell : NSTextFieldCell
@end

@implementation SNRVerticallyCenteredTextFieldCell
- (NSRect)titleRectForBounds:(NSRect)theRect {
    NSRect titleFrame = [super titleRectForBounds:theRect];
    NSSize titleSize = [[self attributedStringValue] size];
    titleFrame.origin.y = theRect.origin.y - .5 + (theRect.size.height - titleSize.height) / 2.0;
    return titleFrame;
}

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
    NSRect titleRect = [self titleRectForBounds:cellFrame];
    [[self attributedStringValue] drawInRect:titleRect];
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{
     NSRect titleRect = [self titleRectForBounds:aRect];
    [super editWithFrame:titleRect inView:controlView editor:textObj delegate:anObject event:theEvent];
}
@end

@implementation SNRVerticallyCenteredTextField

+ (Class)cellClass
{
    return [SNRVerticallyCenteredTextFieldCell class];
}
@end
