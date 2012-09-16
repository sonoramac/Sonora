//
//  SNRProgressIndicator.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-07-15.
//  Copyright 2011 PCWiz Computer. All rights reserved.
//

@interface SNRProgressIndicator : NSView
@property (nonatomic, assign) double maxValue, doubleValue;
- (void)incrementBy:(double)increment;
@end
