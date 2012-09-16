//
//  SNRMetadataWindow.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-01.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRMetadataWindow.h"
#import "SNRMetadataWindowController.h"
#import <Carbon/Carbon.h>

@implementation SNRMetadataWindow
- (void)sendEvent:(NSEvent *)theEvent
{
    // Detect Command + W to close window
    if ([theEvent type] == NSKeyDown) {
        NSUInteger modifierFlags = [theEvent modifierFlags];
        unsigned short keyCode = [theEvent keyCode];
        BOOL commandW = (modifierFlags & NSCommandKeyMask) == NSCommandKeyMask && keyCode == kVK_ANSI_W;
        BOOL escape = !(modifierFlags & NSDeviceIndependentModifierFlagsMask) && keyCode == kVK_Escape;
        if (commandW || escape) {
            [self.windowController hideWindow:nil];
            return;
        }
    }
    [super sendEvent:theEvent];
}

- (void)close
{
    [self.windowController hideWindow:nil];
}
@end
