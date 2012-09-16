//
//  SNRDiscogsEngine.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-18.
//  Copyright (c) 2011 PCWiz Computer. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRDiscogsEngine : NSObject
#pragma mark - Album Artwork

- (void)releaseURLForAlbumWithTitle:(NSString*)title artist:(NSString*)artist completionHandler:(void (^)(NSURL *url, NSError *error))handler;
- (void)artworkURLForAlbumWithTitle:(NSString*)title artist:(NSString*)artist completionHandler:(void (^)(NSURL *url, NSError *error))handler;
- (void)artworkDataForAlbumWithTitle:(NSString*)title artist:(NSString*)artist completionHandler:(void (^)(NSData *data, NSError *error))handler;
@end
