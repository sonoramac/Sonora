//
//  SNRQueuePlayLayer.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-24.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "OEGridLayer.h"
#import "SNRQueueViewCell.h"

@interface SNRQueuePlayLayer : OEGridLayer
@property (nonatomic, assign) BOOL state;
@property (nonatomic, copy) void (^mouseUpBlock)(SNRQueuePlayLayer *layer);
@end
