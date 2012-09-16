//
//  SNRProgressWindowController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-12.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRProgressWindowController.h"

@implementation SNRProgressWindowController {
    NSString *_label;
}
@synthesize progressLabel = _progressLabel;
@synthesize progressIndicator = _progressIndicator;

- (id)initWithLabel:(NSString*)label
{
    if ((self = [super initWithWindowNibName:NSStringFromClass([self class])])) {
        _label = [label copy];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    if (_label) { [self.progressLabel setStringValue:_label]; }
    [self.progressIndicator setIndeterminate:YES];
    [self.progressIndicator startAnimation:nil];
}

@end
