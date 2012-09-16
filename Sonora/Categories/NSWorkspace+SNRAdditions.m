//
//  NSWorkspace+SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-04.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSWorkspace+SNRAdditions.h"

@implementation NSWorkspace (SNRAdditions)
- (BOOL)moveFileToTrash:(NSString*)filePath
{
    if (!filePath) { return NO; }
    return [self performFileOperation:NSWorkspaceRecycleOperation source:[filePath stringByDeletingLastPathComponent] destination:@"" files:[NSArray arrayWithObject:[filePath lastPathComponent]] tag:0];
}
@end
