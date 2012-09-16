//
//  SNRAlbumButtonLayer.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-19.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "OEGridLayer.h"

@interface SNRAlbumButtonLayer : OEGridLayer
@property (nonatomic, copy) void (^mouseUpBlock)(SNRAlbumButtonLayer *layer);
@end
