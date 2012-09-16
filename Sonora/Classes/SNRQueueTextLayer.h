//
//  SNRQueueTextLayer.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-24.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "OEGridLayer.h"
#import "SNRQueueViewCell.h"

@interface SNRQueueTextLayer : OEGridLayer
@property (nonatomic, retain, readonly) CATextLayer *songTextLayer;
@property (nonatomic, retain, readonly) CATextLayer *artistTextLayer;
@property (nonatomic, retain, readonly) CATextLayer *durationTextLayer;
@property (nonatomic, assign) double doubleValue;
@property (nonatomic, assign) double maxValue;
@property (nonatomic, copy) void (^scrubbingBlock)(SNRQueueTextLayer *layer);
@property (nonatomic, copy) void (^hoverBlock)(SNRQueueTextLayer *layer, double hoverValue);
@end
