//
//  SNRLastFMEngine-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-09-12.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRLastFMEngine.h"
#import "SNRSong.h"

@interface SNRLastFMEngine (SNRAdditions)
- (void)scrobbleSong:(SNRSong*)song;
- (void)updateNowPlayingWithSong:(SNRSong*)song;
- (void)loveSong:(SNRSong*)song;
- (void)presentAuthenticationDialogForResponse:(NSDictionary*)response;
@end
