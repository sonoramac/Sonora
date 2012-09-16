//
//  SNREqualizerViewController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-20.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

@protocol SNREqualizerViewControllerDelegate;
@interface SNREqualizerViewController : NSViewController
- (IBAction)equalizerSliderChanged:(id)sender;
- (IBAction)reset:(id)sender;
@property (nonatomic, weak) id<SNREqualizerViewControllerDelegate> delegate;
@end

@protocol SNREqualizerViewControllerDelegate <NSObject>
@optional
- (void)equalizerViewController:(SNREqualizerViewController*)viewController setValue:(float)value forBand:(NSInteger)band;
- (void)equalizerViewControllerResetAllBands:(SNREqualizerViewController *)viewController;
@end