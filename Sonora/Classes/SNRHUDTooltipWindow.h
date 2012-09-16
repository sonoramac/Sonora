//
//  SNRHUDTooltipWindow.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface SNRHUDTooltipWindow : NSWindow
- (id)initWithTitle:(NSString*)title;
- (void)flashAtPoint:(NSPoint)screenPoint;
@end
