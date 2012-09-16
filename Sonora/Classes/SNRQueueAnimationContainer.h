//
//  SNRQueueAnimationContainer.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-19.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

enum {
    SNRQueueAnimationDirectionLeft = 0,
    SNRQueueAnimationDirectionRight = 1
};
typedef NSUInteger SNRQueueAnimationDirection;

@interface SNRQueueAnimationContainer : NSView
@property (nonatomic, strong) NSView *animationView;
@property (nonatomic, assign) SNRQueueAnimationDirection direction;
- (void)renderBottomLayer;
- (void)renderTopLayer;
- (void)animate;
@end
