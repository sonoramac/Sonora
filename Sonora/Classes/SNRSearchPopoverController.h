//
//  SNRSearchPopoverController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-04-13.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRSearchViewController.h"

@interface SNRSearchPopoverController : NSObject <SNRSearchViewControllerDelegate>
@property (nonatomic, retain, readonly) SNRSearchViewController *searchViewController;
+ (SNRSearchPopoverController*)sharedPopoverController;
@end
