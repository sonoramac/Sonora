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

#import "SNRLastFMEngine-SNRAdditions.h"
#import "SNRPreferencesWindowController.h"

#import "SNRAlbum.h"
#import "NSUserDefaults-SNRAdditions.h"

#define kLastFMAuthenticationErrorNumber 9

@implementation SNRLastFMEngine (SNRAdditions)

- (void)scrobbleSong:(SNRSong*)song
{
    [self scrobbleTrackWithName:song.name album:song.album.name artist:song.rawArtist albumArtist:song.rawAlbumArtist trackNumber:[song.trackNumber integerValue] duration:[song.duration integerValue] timestamp:(NSInteger)[[NSDate date] timeIntervalSince1970] completionHandler:^(NSDictionary *scrobbles, NSError *error) {
        [self presentAuthenticationDialogForResponse:scrobbles];
        if (error) { NSLog(@"%@ %@", error, [error userInfo]); }
    }];
}

- (void)updateNowPlayingWithSong:(SNRSong*)song
{
    [self updateNowPlayingTrackWithName:song.name album:song.album.name artist:song.rawArtist albumArtist:song.rawAlbumArtist trackNumber:[song.trackNumber integerValue] duration:[song.duration integerValue] completionHandler:^(NSDictionary *response, NSError *error) {
        [self presentAuthenticationDialogForResponse:response];
        if (error) { NSLog(@"%@ %@", error, [error userInfo]); }
    }];
}

- (void)loveSong:(SNRSong*)song
{
    [self loveTrackWithName:song.name artist:song.rawArtist ?: song.rawAlbumArtist completionHandler:^(NSDictionary *response, NSError *error) {
        [self presentAuthenticationDialogForResponse:response];
        if (error) { NSLog(@"%@ %@", error, [error userInfo]); }
    }];
}

- (void)presentAuthenticationDialogForResponse:(NSDictionary*)response
{
    NSNumber *error = [response valueForKey:@"error"];
    if ([error integerValue] == kLastFMAuthenticationErrorNumber) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"LastFMAuthAlertTitle", nil) defaultButton:NSLocalizedString(@"LastFMAuthAlertDefaultButton", nil) alternateButton:NSLocalizedString(@"LastFMAuthAlertAlternateButton", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"LastFMAuthAlertText", nil)];
        NSInteger response = [alert runModal];
        if (response == NSAlertDefaultReturn) {
            [(id)[SNRPreferencesWindowController sharedPrefsWindowController] authenticateLastFM:nil];
        } else {
            [[NSUserDefaults standardUserDefaults] setLastFMUsername:nil];
            [[SNRLastFMEngine sharedInstance] setUsername:nil];
        }
    }
}
@end
