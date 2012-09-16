//
//  NSFileManager-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-29.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

@interface NSFileManager (SNRAdditions)
- (NSArray*)recursiveContentsOfDirectoryAtPath:(NSString*)path;
@end
