//
//  SNRArtistsStaticNode.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtistsNode.h"
#import "SNRSearchObject.h"

enum {
    SNRArtistsStaticNodeTypeNone = 0,
    SNRArtistsStaticNodeTypeAlbums = 1,
    SNRArtistsStaticNodeTypeMixes = 2,
    SNRArtistsStaticNodeTypeCompilations = 3
};
typedef NSUInteger SNRArtistsStaticNodeType;

@interface SNRArtistsStaticNode : SNRArtistsNode <SNRSearchObject>
@property (nonatomic, assign, readonly) SNRArtistsStaticNodeType type;
- (id)initWithType:(SNRArtistsStaticNodeType)type;
@end
