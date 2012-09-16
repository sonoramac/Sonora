//
//  SNRManagedObject.m
//  Sonora
//
//  Created by Indragie Karunaratne on 12-03-14.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRManagedObject.h"
#import "SNRSearchIndex.h"
#import "SNRQueueCoordinator.h"

@implementation SNRManagedObject
- (void)deleteFromContextAndSearchIndex
{
    SNRSearchIndex *index = [SNRSearchIndex sharedIndex];
    [index setKeywords:nil forObjectID:[self objectID]];
    [self deleteAndPropagateChanges];
}

- (void)deleteFromLibraryAndFromDisk:(BOOL)disk {
    [self deleteFromContextAndSearchIndex];
}

- (void)deleteAndPropagateChanges
{
    [[self managedObjectContext] deleteObject:self];
    [[self managedObjectContext] processPendingChanges];
}

- (BOOL)isDeletableFromDisk
{
    return NO;
}

- (NSImage*)searchArtwork
{
    return nil;
}

- (NSImage*)searchIcon
{
    return nil;
}

- (NSString*)searchStatisticText
{
    return nil;
}

- (NSString*)searchSubtitleText
{
    return nil;
}

- (NSArray*)songsArray
{
    return nil;
}

- (void)enqueue
{
    [SNR_MainQueueController enqueueSongs:self.songsArray];
}

- (void)play
{
    [SNR_MainQueueController playSongs:self.songsArray];
}

- (void)shuffle
{
    [SNR_MainQueueController shuffleSongs:self.songsArray];
}

#pragma mark - Pasteboard Writing

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard
{
    [pasteboard writeObjects:self.songsArray];
    return nil;
}

- (id)pasteboardPropertyListForType:(NSString *)type
{
    return nil;
}
@end
