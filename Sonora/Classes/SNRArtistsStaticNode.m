//
//  SNRArtistsStaticNode.m
//  Sonora
//
//  Created by Indragie Karunaratne on 2012-08-17.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

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

