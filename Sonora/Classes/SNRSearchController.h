//
//  SNRSearchController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-04-07.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRSearchController : NSObject
@property (nonatomic, retain) NSArray *searchResults;
- (void)performSearchForQuery:(NSString*)query handler:(void(^)(SNRSearchController *controller))handler;
- (void)clearSearchQuery;

- (void)openSearchResultWithObject:(id)object;
- (void)enqueueObject:(id)object;
- (void)playObject:(id)object;
@end
