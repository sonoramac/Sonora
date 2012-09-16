//
//  SNRProgressWindowController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-12.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SNRProgressWindowController : NSWindowController
@property (nonatomic, weak) IBOutlet NSTextField *progressLabel;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressIndicator;
- (id)initWithLabel:(NSString*)label;
@end
