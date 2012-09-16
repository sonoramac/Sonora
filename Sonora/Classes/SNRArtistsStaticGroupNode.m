//
//  SNRArtistsStaticGroupNode.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtistsStaticGroupNode.h"

@implementation SNRArtistsStaticGroupNode {
    NSMutableArray *_groupChildren;
    SNRArtistsStaticNode *_albums;
    SNRArtistsStaticNode *_compilations;
    SNRArtistsStaticNode *_mixes;
}
@synthesize albums = _albums;
@synthesize compilations = _compilations;
@synthesize mixes = _mixes;

- (id)init
{
    if ((self = [super init])) {
        _albums = [[SNRArtistsStaticNode alloc] initWithType:SNRArtistsStaticNodeTypeAlbums];
        _groupChildren = [NSMutableArray arrayWithObject:_albums];
    }
    return self;
}

#pragma mark - Accessors

- (void)setShowCompilations:(BOOL)showCompilations
{
    if (!showCompilations && _compilations) {
        [_groupChildren removeObject:_compilations];
        _compilations = nil;
    } else if (showCompilations && !_compilations) {
        _compilations = [[SNRArtistsStaticNode alloc] initWithType:SNRArtistsStaticNodeTypeCompilations];
        [_groupChildren addObject:_compilations];
    }
}

- (BOOL)showCompilations
{
    return (_compilations != nil);
}

- (void)setShowMixes:(BOOL)showMixes
{
    if (!showMixes && _mixes) {
        [_groupChildren removeObject:_mixes];
        _mixes = nil;
    } else if (showMixes && !_mixes) {
        _mixes = [[SNRArtistsStaticNode alloc] initWithType:SNRArtistsStaticNodeTypeMixes];
        if (self.showCompilations) {
            [_groupChildren insertObject:_mixes atIndex:1];
        } else {
            [_groupChildren addObject:_mixes];
        }
    }
}

- (BOOL)showMixes
{
    return (_mixes != nil);
}

- (NSArray *)children
{
    return _groupChildren;
}
@end
