//
//  SNRAlbumEmptyView.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-20.
//  Copyright (c) 2012 Sonora. All rights reserved.
//

#import "SNRAlbumEmptyView.h"

#import "NSShadow-SNRAdditions.h"

#define kTextColor [NSColor colorWithDeviceRed:0.49 green:0.55 blue:0.62 alpha:1.0]
#define kTextFont [NSFont systemFontOfSize:26.f]

@implementation SNRAlbumEmptyView
@synthesize text = _text;

- (void)drawRect:(NSRect)dirtyRect
{
    if (!self.text) { return; }
    NSShadow *textShadow = [NSShadow shadowWithOffset:NSMakeSize(0.f, -1.f) blurRadius:1.f color:[NSColor colorWithDeviceWhite:1.f alpha:0.5f]];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:textShadow, NSShadowAttributeName, kTextColor, NSForegroundColorAttributeName, kTextFont, NSFontAttributeName, nil];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
    NSSize textSize = [attributedText size];
    NSRect textRect = NSMakeRect(NSMidX([self bounds]) - (textSize.width / 2.f), NSMidY([self bounds]) - (textSize.height / 2.f), textSize.width, textSize.height);
    [attributedText drawInRect:NSIntegralRect(textRect)];
}

- (void)setText:(NSString *)text
{
    if (_text != text) {
        _text = text;
        [self setNeedsDisplay:YES];
    }
}

@end
