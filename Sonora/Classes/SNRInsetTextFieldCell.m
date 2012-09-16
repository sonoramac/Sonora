//
//  SNRInsetTextFieldCell.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-15.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRInsetTextFieldCell.h"

#define kTextShadowColor [NSColor colorWithCalibratedWhite:1.f alpha:0.3f]

@implementation SNRInsetTextFieldCell

- (id)initWithCoder:(NSCoder*)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self setBackgroundStyle:NSBackgroundStyleRaised];
    }
    return self;
}


@end
