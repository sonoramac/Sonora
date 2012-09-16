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

#import "SNRArtistsStaticNode.h"
static NSString* const kImageSearchIcon = @"nav-Template";

@implementation SNRArtistsStaticNode

- (id)initWithType:(SNRArtistsStaticNodeType)type
{
    if ((self = [super init])) {
        _type = type;
        switch (_type) {
            case SNRArtistsStaticNodeTypeMixes:
                self.name = NSLocalizedString(@"Mixes", nil);
                break;
            case SNRArtistsStaticNodeTypeAlbums:
                self.name = NSLocalizedString(@"Albums", nil);
                break;
            case SNRArtistsStaticNodeTypeCompilations:
                self.name = NSLocalizedString(@"Compilations", nil);
                break;
            default:
                break;
        }
    }
    return self;
}

#pragma mark - Comparison 

- (BOOL)isEqual:(id)object
{
    return [object isKindOfClass:[self class]] && self.type == [(SNRArtistsStaticNode*)object type];
}

- (NSUInteger)hash
{
    return self.type;
}

#pragma mark - SNRSearchObject

- (NSImage*)searchArtwork { return nil; }
- (NSImage*)searchIcon { return [NSImage imageNamed:kImageSearchIcon]; }
- (NSString*)searchSubtitleText { return nil; }
- (NSString*)searchStatisticText { return nil; }
@end

