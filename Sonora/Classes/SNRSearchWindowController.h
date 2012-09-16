//
//  SNRSearchWindowController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-03.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

@class SNRSearchViewController;
@interface SNRSearchWindowController : NSWindowController
@property (nonatomic, assign) BOOL openedViaShortcut;
@property (nonatomic, retain) IBOutlet SNRSearchViewController *searchViewController;
+ (SNRSearchWindowController*)sharedWindowController;
- (IBAction)hideWindow:(id)sender;
- (IBAction)toggleVisible:(id)sender;
@end
