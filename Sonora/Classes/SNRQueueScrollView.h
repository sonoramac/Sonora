//
//  SNRQueueScrollView.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-22.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SNRCustomScrollView.h"

@interface SNRQueueScrollView : SNRCustomScrollView
@property (nonatomic, assign) BOOL blockScrollEvents;
@end
