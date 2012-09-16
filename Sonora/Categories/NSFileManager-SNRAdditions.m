//
//  NSFileManager-SNRAdditions.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-29.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "NSFileManager-SNRAdditions.h"

@implementation NSFileManager (SNRAdditions)
- (NSArray*)recursiveContentsOfDirectoryAtPath:(NSString*)path
{
    NSDirectoryEnumerator *enumerator = [self enumeratorAtURL:[NSURL fileURLWithPath:path] includingPropertiesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] options:NSDirectoryEnumerationSkipsHiddenFiles errorHandler:nil];
    NSMutableArray *paths = [NSMutableArray array];
    for (NSURL *url in enumerator) {
        NSNumber *isDirectory;
        [url getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
        if (![isDirectory boolValue]) {
            [paths addObject:url.path];
        }
    }
    return paths;
}
@end
