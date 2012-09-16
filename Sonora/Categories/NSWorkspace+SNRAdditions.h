//
//  NSWorkspace+SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-04.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface NSWorkspace (SNRAdditions)
- (BOOL)moveFileToTrash:(NSString*)filePath;
@end
