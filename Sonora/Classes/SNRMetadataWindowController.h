//
//  SNRMetadataWindowController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-30.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRMetadataViewController.h"

extern NSString* const SNRMetadataWindowControllerSelectionChangedNotification;
extern NSString* const SNRMetadataWindowControllerSelectionChangedEntityNameKey;
extern NSString* const SNRMetadataWindowControllerSelectionChangedItemsKey;
extern NSString* const SNRMetadataWindowControllerSelectionChangedSelectedKey;

@interface SNRMetadataWindowController : NSWindowController <SNRMetadataViewControllerDelegate>
+ (SNRMetadataWindowController*)sharedWindowController;
- (void)hideWindow:(id)sender;
@end
