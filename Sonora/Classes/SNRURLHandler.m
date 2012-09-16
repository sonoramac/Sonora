/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
