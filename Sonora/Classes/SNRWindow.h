//
//  SNRWindow.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-13.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

extern NSString* const SNRWindowEscapeKeyPressedNotification;
extern NSString* const SNRWindowSpaceKeyPressedNotification;
extern NSString* const SNRWindowLeftKeyPressedNotification;
extern NSString* const SNRWindowRightKeyPressedNotification;
extern NSString* const SNRWindowEscEndedEditingNotification;

#import "INAppStoreWindow.h"

@interface SNRWindow : INAppStoreWindow <NSDraggingDestination, NSWindowDelegate>
@property (nonatomic, weak) IBOutlet NSView *toolbarView;
@end