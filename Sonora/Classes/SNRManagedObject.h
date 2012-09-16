//
//  SNRManagedObject.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-14.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "SNRSearchObject.h"

@interface SNRManagedObject : NSManagedObject <NSPasteboardWriting, SNRSearchObject>
#pragma mark - Deletion

- (void)deleteAndPropagateChanges;
- (void)deleteFromContextAndSearchIndex;
- (void)deleteFromLibraryAndFromDisk:(BOOL)disk;
- (BOOL)isDeletableFromDisk;

#pragma mark - Playback

@property (nonatomic, readonly) NSArray *songsArray;
- (void)enqueue;
- (void)play;
- (void)shuffle;
@end
