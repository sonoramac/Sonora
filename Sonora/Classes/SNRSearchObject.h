//
//  SNRSearchObject.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SNRSearchObject <NSObject>
- (NSImage*)searchArtwork;
- (NSImage*)searchIcon;
- (NSString*)searchSubtitleText;
- (NSString*)searchStatisticText;
@end
