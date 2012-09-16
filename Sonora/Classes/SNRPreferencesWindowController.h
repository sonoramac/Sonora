//
//  SNRPreferencesWindowController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-09-12.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//
#import "DBPrefsWindowController.h"

@class SRRecorderControl;
@class MASShortcutView;
@interface SNRPreferencesWindowController : DBPrefsWindowController
@property (nonatomic, weak) IBOutlet NSView *general;
@property (nonatomic, weak) IBOutlet NSView *sync;
@property (nonatomic, weak) IBOutlet NSView *lastFM;
@property (nonatomic, weak) IBOutlet MASShortcutView *searchShortcutView;
@property (nonatomic, weak) IBOutlet NSButton *lastFMButton;
@property (nonatomic, weak) IBOutlet NSTextField *lastFMField;
- (IBAction)authenticateLastFM:(id)sender;
- (IBAction)changePath:(id)sender;
- (IBAction)resetPath:(id)sender;
@end
