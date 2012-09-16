//
//  SNRLastFMEngine-SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-09-12.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

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
