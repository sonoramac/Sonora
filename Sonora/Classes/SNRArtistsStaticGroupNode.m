/*
 *  Copyright (C) 2012 Indragie Karunaratne <i@indragie.com>
 *  All Rights Reserved.
 *
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are
 *  met:
 *
 *    - Redistributions of source code must retain the above copyright
 *      notice, this list of conditions and the following disclaimer.
 *    - Redistributions in binary form must reproduce the above copyright
 *      notice, this list of conditions and the following disclaimer in the
 *      documentation and/or other materials provided with the distribution.
 *    - Neither the name of Indragie Karunaratne nor the names of its
 *      contributors may be used to endorse or promote products derived
 *      from this software without specific prior written permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 *  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 *  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 *  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 *  HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 *  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 *  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 *  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 *  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 *  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
