//
//  NSButton+SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-26.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSButton+SNRAdditions.h"
#import "NSString-SNRAdditions.h"

@implementation NSButton (SNRAdditions)
- (NSColor *)textColor
{
    return [[self attributedTitle] color];
}

- (void)setTextColor:(NSColor *)textColor
{
    [self setAttributedTitle:[[self attributedTitle] attributedStringWithColor:textColor]];
}

- (NSColor *)alternateTextColor
{
    return [[self attributedAlternateTitle] color];
}

- (void)setAlternateTextColor:(NSColor *)alternateTextColor
{
    NSAttributedString *string = self.attributedAlternateTitle ?: self.attributedTitle;
    [self setAttributedAlternateTitle:[string attributedStringWithColor:alternateTextColor]];
}
@end
