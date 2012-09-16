//
//  SNRMetadataTextFieldCell.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-31.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRMetadataTextFieldCell.h"

#import "NSShadow-SNRAdditions.h"

#define kTextShadowOffset            NSMakeSize(0.f, 1.f)
#define kTextShadowBlurRadius        1.f
#define kTextShadowColor             [NSColor blackColor]

@implementation SNRMetadataTextFieldCell

- (void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    if (!self.attributedStringValue) { return; }
    NSDictionary *existingAttributes = [self.attributedStringValue attributesAtIndex:0 effectiveRange:NULL];
    NSMutableDictionary *newAttributes = [NSMutableDictionary dictionaryWithDictionary:existingAttributes];
    NSShadow *shadow = [NSShadow shadowWithOffset:kTextShadowOffset blurRadius:kTextShadowBlurRadius color:kTextShadowColor];
    [newAttributes setValue:shadow forKey:NSShadowAttributeName];
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:self.stringValue attributes:newAttributes];
    [string drawInRect:cellFrame];
}
@end
