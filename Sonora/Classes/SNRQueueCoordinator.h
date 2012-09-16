//
//  SNRQueueCoordinator.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRQueueController.h"
#import "HIDRemote.h"

@class SNRQueueView;
@class SNRMix;
@interface SNRQueueCoordinator : NSResponder <HIDRemoteDelegate, NSPopoverDelegate, NSWindowDelegate, NSMenuDelegate>
@property (nonatomic, strong, readonly) NSArray *queueControllers;
@property (nonatomic, strong) SNRQueueController *activeQueueController;

@property (nonatomic, weak) IBOutlet SNRQueueView *mainQueueView;

@property (nonatomic, weak) IBOutlet NSButton *repeatButton;
@property (nonatomic, strong) IBOutlet NSView *mainButtonsContainer;
@property (nonatomic, strong) IBOutlet NSView *mixButtonsContainer;

- (SNRQueueController *)mainQueueController;
- (SNRQueueController *)mixQueueController;

- (void)showMixEditingQueueControllerForMix:(SNRMix*)mix;

// Main Queue Buttons
- (IBAction)volume:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)repeat:(id)sender;
- (IBAction)shuffle:(id)sender;

// Mix Editing Buttons
- (IBAction)saveMix:(id)sender;
- (IBAction)cancelMix:(id)sender;
@end
