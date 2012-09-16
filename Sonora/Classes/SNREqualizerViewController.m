//
//  SNREqualizerViewController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-20.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNREqualizerViewController.h"

@interface SNREqualizerViewController ()
- (void)setEQValue:(float)value forBand:(NSInteger)band;
@end

@implementation SNREqualizerViewController
@synthesize delegate = _delegate;

- (id)init
{
    return [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (IBAction)equalizerSliderChanged:(id)sender
{
    [self setEQValue:[sender floatValue] forBand:[sender tag]];
}

- (void)setEQValue:(float)value forBand:(NSInteger)band
{
    if ([self.delegate respondsToSelector:@selector(equalizerViewController:setValue:forBand:)]) {
        [self.delegate equalizerViewController:self setValue:value forBand:band];
    }
}

- (IBAction)reset:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(equalizerViewControllerResetAllBands:)]) {
        [self.delegate equalizerViewControllerResetAllBands:self];
    }
}
@end
