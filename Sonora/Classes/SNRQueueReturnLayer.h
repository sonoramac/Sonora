//
//  SNRQueueReturnLayer.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-26.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "OEGridLayer.h"

@interface SNRQueueReturnLayer : OEGridLayer
@property (nonatomic, assign) BOOL showRightArrow;
@property (nonatomic, copy) void (^mouseUpBlock)(SNRQueueReturnLayer *layer);
@end
