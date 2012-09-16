//
//  SNRAlbumTextLayer.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-11.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "OEGridLayer.h"

@interface SNRAlbumTextLayer : OEGridLayer
@property (nonatomic, retain, readonly) CATextLayer *albumTextLayer;
@property (nonatomic, retain, readonly) CATextLayer *artistTextLayer;
@property (nonatomic, retain, readonly) CATextLayer *durationTextLayer;
@end
