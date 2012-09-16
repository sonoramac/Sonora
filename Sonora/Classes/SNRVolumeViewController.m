//
//  SNRVolumeViewController.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-05-18.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRVolumeViewController.h"

@interface SNRVolumeViewController ()

@end

@implementation SNRVolumeViewController
@synthesize bas = _bas;
@synthesize mid = _mid;
@synthesize tre = _tre;

- (id)init
{
    return [super initWithNibName:NSStringFromClass([self class]) bundle:nil];
}

- (IBAction)mid:(id)sender
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setFloat:([self.bas minValue] + [self.bas maxValue])/2 forKey:@"eqBas"];
    [ud setFloat:([self.mid minValue] + [self.mid maxValue])/2 forKey:@"eqMid"];
    [ud setFloat:([self.tre minValue] + [self.tre maxValue])/2 forKey:@"eqTre"];
}
@end
