//
//  SNRUIController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-01.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RBSplitView, SNRWindow;
@interface SNRUIController : NSObject <NSWindowDelegate, NSMenuDelegate>
@property (nonatomic, weak) IBOutlet NSSplitView *splitView;
@property (nonatomic, assign) IBOutlet SNRWindow *mainWindow;
@property (nonatomic, weak) IBOutlet NSView *artistsView;
- (IBAction)showHideArtistsView:(id)sender;
@end
