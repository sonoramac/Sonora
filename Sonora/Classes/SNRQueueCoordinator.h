/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
