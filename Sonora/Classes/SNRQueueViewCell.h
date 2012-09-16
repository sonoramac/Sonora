//
//  SNRQueueViewCell.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-22.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "OEGridViewCell.h"
#import "SNRQueueController.h"

@interface SNRQueueViewCell : OEGridViewCell
@property (nonatomic, copy) NSString *songName;

@property (nonatomic, copy) NSString *artistName;
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, assign) BOOL nowPlaying;
@property (nonatomic, assign) BOOL playbackState;

@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, assign) NSTimeInterval remainingTime;
@property (nonatomic, assign) double progressDoubleValue;
@property (nonatomic, assign) double progressMaxValue;

@property (nonatomic, retain) id representedObject;
@property (nonatomic, assign) BOOL dimmed;

@property (nonatomic, weak) SNRQueueController *queueController;
- (void)setNowPlaying:(BOOL)playing animated:(BOOL)animated;
@end
