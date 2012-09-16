//
//  SNRArtistsArrayControllerNode.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtistsArrayControllerNode.h"

@implementation SNRArtistsArrayControllerNode {
    NSArrayController *_arrayController;
}
@synthesize arrayController = _arrayController;

- (id)initWithArrayController:(NSArrayController *)arrayController
{
    if ((self = [super init])) {
        _arrayController = arrayController;
    }
    return self;
}

- (NSArray*)children
{
    return [_arrayController arrangedObjects];
}
@end
