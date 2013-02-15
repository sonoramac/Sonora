//
//  SNRArtworkStore.h
//  Sonora
//
//  Created by Edward Barnard on 13/02/2013.
//  Copyright (c) 2013 Sonora. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRArtworkStore : NSObject

- (id) initWithName:(NSString*) name;
- (NSURL*) artworkPathForObject:(id)object;
- (NSData*) artworkForObject:(id)object;
- (void) setArtworkForObject:(id)object data:(NSData*)data;

@end
