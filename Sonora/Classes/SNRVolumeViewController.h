//
//  SNRVolumeViewController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-05-18.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SNRVolumeViewController : NSViewController
@property (nonatomic, weak) IBOutlet NSSlider *bas;
@property (nonatomic, weak) IBOutlet NSSlider *mid;
@property (nonatomic, weak) IBOutlet NSSlider *tre;
- (IBAction)mid:(id)sender;
@end
