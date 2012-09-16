//
//  SNRURLHandler.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-09-12.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRURLHandler.h"
#import "SNRLastFMEngine.h"

#import "NSUserDefaults-SNRAdditions.h"

static NSString* const kCustomURLScheme = @"sonora";
static NSString* const kIdentifierLastFM = @"lastfmauth";
static NSString* const kLastFMTokenPrefix = @"?token=";

@interface SNRURLHandler ()
- (void)getURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent;
- (void)authenticateLastFMWithTokenString:(NSString*)string;
@end

@implementation SNRURLHandler

- (void)registerURLHandlers
{
    // Register URL handler
    NSAppleEventManager *em = [NSAppleEventManager sharedAppleEventManager];
    [em setEventHandler:self andSelector:@selector(getURL:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    LSSetDefaultHandlerForURLScheme((__bridge CFStringRef)kCustomURLScheme, (__bridge CFStringRef)bundleID);
}

- (void)getURL:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent
{
    NSString *urlString = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
    NSArray *components = [urlString pathComponents];
    if ([components count] < 2) { return; }
    NSString *identifier = [components objectAtIndex:1];
    if ([identifier isEqualToString:kIdentifierLastFM]) {
        [self authenticateLastFMWithTokenString:[components objectAtIndex:2]];
    }
}

- (void)authenticateLastFMWithTokenString:(NSString*)string
{
    NSString *token = [string stringByReplacingOccurrencesOfString:kLastFMTokenPrefix withString:@""];
    [[SNRLastFMEngine sharedInstance] retrieveAndStoreSessionKeyWithToken:token completionHandler:^(NSString *user, NSError *error) {
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        if (error) { NSLog(@"%@, %@", error, [error userInfo]); }
        ud.lastFMUsername = user;
    }];
}
@end
