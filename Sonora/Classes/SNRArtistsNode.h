//
//  SNRArtistsNode.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SNRArtistsNode : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) NSArray *children;
@property (nonatomic, assign, getter = isGroupNode) BOOL groupNode;
@end



