//
//  SNRBlockMenuItem.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-25.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRBlockMenuItem.h"

@interface SNRBlockMenuItem ()
- (void)menuAction:(NSMenuItem*)item;
@end

@implementation SNRBlockMenuItem
@synthesize block = _block;

- (id)initWithTitle:(NSString *)title keyEquivalent:(NSString *)key block:(void (^)(NSMenuItem *item))block
{
    if ((self = [super initWithTitle:title action:@selector(menuAction:) keyEquivalent:key])) {
        self.target = self;
        self.block = block;
    }
    return self;
}

- (void)menuAction:(NSMenuItem*)item
{
    if (item == self && self.block) {
        self.block(item);
    }
}

@end
