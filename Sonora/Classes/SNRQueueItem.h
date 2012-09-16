//
//  SNRQueueItem.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SNRSong.h"

@interface SNRQueueItem : NSObject <NSCopying, NSCoding>
- (void)lastFMUpdateNowPlaying;
- (void)lastFMLoveTrack;
- (void)postGrowlNotification;
@property (nonatomic, strong) SNRSong *song;
@property (nonatomic, assign) BOOL played;
@end