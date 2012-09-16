//
//  SNRArtworkCache.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-22.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRArtworkCache : NSObject
#pragma mark - Cache Access
- (void)setCachedArtwork:(NSImage*)artwork forObject:(id)object;
- (void)removeAllCachedArtwork;
- (void)removeCachedArtworkForObject:(id)object;

#pragma mark - Image Retrieval
- (NSImage*)asynchronousCachedArtworkForObject:(id)object artworkSize:(NSSize)size asyncHandler:(void (^)(NSImage *image))handler;
- (NSImage*)synchronousCachedArtworkForObject:(id)object artworkSize:(NSSize)size;

#pragma mark - Image Processing
+ (NSImage*)scaledArtworkWithData:(NSData*)data artworkSize:(NSSize)size;
@end
