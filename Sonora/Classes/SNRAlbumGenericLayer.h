//
//  SNRAlbumGenericLayer.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-12.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "OEGridLayer.h"

@interface SNRAlbumGenericLayer : OEGridLayer
@property (nonatomic, retain, readonly) CATextLayer *albumTextLayer;
@property (nonatomic, retain, readonly) CATextLayer *artistTextLayer;
@end
