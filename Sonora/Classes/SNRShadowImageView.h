//
//  SNRShadowImageView.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-09.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SNRShadowImageViewDelegate;
@interface SNRShadowImageView : NSView
@property (nonatomic, retain) NSImage *image;
@property (nonatomic, retain) NSShadow *shadow;
@end
