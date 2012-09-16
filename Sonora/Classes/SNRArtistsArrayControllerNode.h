//
//  SNRArtistsArrayControllerNode.h
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtistsNode.h"

@interface SNRArtistsArrayControllerNode : SNRArtistsNode
@property (nonatomic, strong, readonly) NSArrayController *arrayController;
- (id)initWithArrayController:(NSArrayController*)arrayController;
@end
