//
//  SNRHotKeyManager.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-04-21.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRHotKeyManager.h"
#import "SNRSearchWindowController.h"
#import "SNRSearchViewController.h"

#import "NSWindow+SNRAdditions.h"

@implementation SNRHotKeyManager

+ (SNRHotKeyManager*)sharedManager
{
    static SNRHotKeyManager *manager;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
       manager = [[self alloc] init];
    });
    return manager;
}

- (void)registerHotKeys
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    if (![[ud objectForKey:kUserDefaultsSearchShortcutKey] isKindOfClass:[NSData class]]) {
        // Set up the default search shortcut
        MASShortcut *shortcut = [MASShortcut shortcutWithKeyCode:kVK_ANSI_Period modifierFlags:NSCommandKeyMask];
        [ud setObject:[shortcut data] forKey:kUserDefaultsSearchShortcutKey];
    }
    [MASShortcut registerGlobalShortcutWithUserDefaultsKey:kUserDefaultsSearchShortcutKey handler:^{
        SNRSearchWindowController *search = [SNRSearchWindowController sharedWindowController];
        if ([search.window isVisible]) {
            search.openedViaShortcut = NO;
            [NSApp hide:nil];
            [search hideWindow:nil];
        } else {
            if (![NSApp isActive]) {
                for (NSWindow *window in [NSApp windows]) {
                    if (![window isFullscreen]) {
                        [window orderOut:nil];
                    }
                }
                [NSApp activateIgnoringOtherApps:YES];
                search.openedViaShortcut = YES;
            }
            [search.window makeFirstResponder:search.searchViewController.searchField];
            [search showWindow:nil];
        }
    }];
}
@end
