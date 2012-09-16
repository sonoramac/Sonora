//
//  SNRArtistsStaticGroupNode.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtistsNode.h"
#import "SNRArtistsStaticNode.h"

@interface SNRArtistsStaticGroupNode : SNRArtistsNode
@property (nonatomic, strong, readonly) SNRArtistsStaticNode *albums;
@property (nonatomic, strong, readonly) SNRArtistsStaticNode *mixes;
@property (nonatomic, strong, readonly) SNRArtistsStaticNode *compilations;

@property (nonatomic, assign) BOOL showMixes;
@property (nonatomic, assign) BOOL showCompilations;
@end
