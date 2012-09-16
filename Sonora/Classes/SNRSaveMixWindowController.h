//
//  SNRSaveMixWindowController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-05-03.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SNRSaveMixWindowController : NSWindowController
@property (nonatomic, weak) IBOutlet NSTextField *nameField;
@property (nonatomic, retain, readonly) NSArray *songs;
- (id)initWithSongs:(NSArray*)songs;
- (IBAction)ok:(id)sender;
- (IBAction)cancel:(id)sender;
@end
