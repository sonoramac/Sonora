//
//  SNRSharedImageCache.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-21.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRSharedImageCache : NSObject
+ (SNRSharedImageCache*)sharedInstance;
@property (nonatomic, readonly) CGImageRef noiseImage;
- (void)drawNoiseImage;
@end
