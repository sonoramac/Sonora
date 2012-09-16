//
//  SNRAboutWindowController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SNRAboutWindowController : NSWindowController
@property (nonatomic, weak) IBOutlet NSButton *facebookButton;
@property (nonatomic, weak) IBOutlet NSButton *twitterButton;
@property (nonatomic, weak) IBOutlet NSButton *webButton;
@property (nonatomic, weak) IBOutlet NSTextField *versionLabel;
@property (nonatomic, retain) IBOutlet NSView *mainView;
@property (nonatomic, retain) IBOutlet NSView *creditsView;
@property (nonatomic, assign) IBOutlet NSTextView *creditsTextView;
+ (SNRAboutWindowController*)sharedWindowController;
- (IBAction)facebook:(id)sender;
- (IBAction)twitter:(id)sender;
- (IBAction)web:(id)sender;
- (IBAction)indragie:(id)sender;
- (IBAction)tyler:(id)sender;
- (IBAction)credits:(id)sender;
@end
