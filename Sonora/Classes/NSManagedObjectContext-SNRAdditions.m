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

#import "NSManagedObjectContext-SNRAdditions.h"
#import "SNRSearchIndex-SNRAdditions.h"
#import "SNRAudioMetadata.h"

NSString* const kCompilationsArtistName = @"Various Artists";

@implementation NSManagedObjectContext (SNRAdditions)
- (BOOL)saveChanges
{
    [[SNRSearchIndex sharedIndex] flush];
    NSError *error = nil;
    if (![self save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        return NO;
    }
    return YES;
}

- (id)createObjectOfEntityName:(NSString*)entityName
{
    return [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:self];
}

- (BOOL)deleteObjects:(NSArray*)objects ofEntity:(NSString*)entity
{
    NSEntityDescription *e = [NSEntityDescription entityForName:entity inManagedObjectContext:self];
    NSArray *relationships = [[e relationshipsByName] allKeys];
    [self fetchObjectsOfEntity:entity sortDescriptors:nil predicate:[NSPredicate predicateWithFormat:@"SELF IN %@", objects] batchSize:0 fetchLimit:0 relationshipKeyPathsForPrefetching:relationships];
    for (NSManagedObject *object in objects) {
        [self deleteObject:object];
    }
    return [self saveChanges];
}

- (NSArray*)fetchObjectsOfEntity:(NSString*)entity sortDescriptors:(NSArray*)descriptors predicate:(NSPredicate*)predicate batchSize:(NSUInteger)batchSize fetchLimit:(NSUInteger)limit relationshipKeyPathsForPrefetching:(NSArray*)keypaths
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
	[fetchRequest setEntity:[NSEntityDescription entityForName:entity inManagedObjectContext:self]];
	[fetchRequest setSortDescriptors:descriptors];
	[fetchRequest setPredicate:predicate];
    [fetchRequest setFetchBatchSize:batchSize];
    [fetchRequest setFetchLimit:limit];
    [fetchRequest setRelationshipKeyPathsForPrefetching:keypaths];
    [fetchRequest setShouldRefreshRefetchedObjects:YES];
	NSError *error = nil;
	NSArray *fetchedObjects = [self executeFetchRequest:fetchRequest error:&error];
	if (error) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	}
	return fetchedObjects;
}

- (SNRArtist*)artistWithName:(NSString*)name create:(BOOL)create
{
    if (![name length]) { name = NSLocalizedString(@"UntitledArtist", nil); }
    NSString *normalizedName = [SNRArtist sortNameForArtistName:name];
    NSArray *fetchedObjects = [self fetchObjectsOfEntity:kEntityNameArtist sortDescriptors:nil predicate:[NSPredicate predicateWithFormat:@"sortingName == %@", normalizedName] batchSize:0 fetchLimit:1 relationshipKeyPathsForPrefetching:nil];
	if (![fetchedObjects count]) {
        if (create) {
            SNRArtist *artist = [self createObjectOfEntityName:kEntityNameArtist];
            artist.name = name;
            return artist;
        }
        return nil;
	}
	return [fetchedObjects objectAtIndex:0];	
}

- (SNRMix*)mixWithiTunesPersistentID:(NSString*)iTunesPersistentID
{
    NSArray *fetchedObjects = [self fetchObjectsOfEntity:kEntityNameMix sortDescriptors:nil predicate:[NSPredicate predicateWithFormat:@"iTunesPersistentID == %@", iTunesPersistentID] batchSize:0 fetchLimit:1 relationshipKeyPathsForPrefetching:nil];
	if (![fetchedObjects count]) {
		SNRMix *mix = [self createObjectOfEntityName:kEntityNameMix];
        mix.iTunesPersistentID = iTunesPersistentID;
        mix.dateModified = [NSDate date];
        return mix;
	}
    return [fetchedObjects objectAtIndex:0];
}

- (SNRSong*)songWithiTunesPersistentID:(NSString*)iTunesPersistentID
{
    NSArray *fetchedObjects = [self fetchObjectsOfEntity:kEntityNameSong sortDescriptors:nil predicate:[NSPredicate predicateWithFormat:@"iTunesPersistentID == %@", iTunesPersistentID] batchSize:0 fetchLimit:1 relationshipKeyPathsForPrefetching:nil];
    if ([fetchedObjects count]) { return [fetchedObjects objectAtIndex:0]; }
    return nil;
}

- (SNRArtist*)compilationsArtist
{
    return [self artistWithName:kCompilationsArtistName create:YES];
}

- (SNRAlbum*)albumWithName:(NSString*)name byArtist:(SNRArtist*)artist create:(BOOL)create
{
    if (![name length]) { name = NSLocalizedString(@"UntitledAlbum", nil); }
    NSArray *fetchedObjects = [self fetchObjectsOfEntity:kEntityNameAlbum sortDescriptors:nil predicate:[NSPredicate predicateWithFormat:@"(name == %@) AND (artist == %@)", name, artist] batchSize:0 fetchLimit:1 relationshipKeyPathsForPrefetching:nil];
	if (![fetchedObjects count]) {
        if (create) {
            SNRAlbum *album = [self createObjectOfEntityName:kEntityNameAlbum];
            album.name = name;
            album.artist = artist;
            return album;
        }
        return nil;
	}
	return [fetchedObjects objectAtIndex:0];
}

- (NSArray*)songsWithName:(NSString*)name albumName:(NSString*)albumName artistName:(NSString*)artistName
{
    if (![name length]) { name = NSLocalizedString(@"UntitledSong", nil); }
    if (![albumName length]) { albumName = NSLocalizedString(@"UntitledAlbum", nil); }
    if (![artistName length]) { artistName = NSLocalizedString(@"UntitledArtist", nil); }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@ AND album.name == %@ AND album.artist.name == %@", name, albumName, artistName];
    NSArray *fetchedObjects = [self fetchObjectsOfEntity:kEntityNameSong sortDescriptors:nil predicate:predicate batchSize:0 fetchLimit:0 relationshipKeyPathsForPrefetching:nil];
    return fetchedObjects;
}

- (NSArray*)songsAtSourcePath:(NSString*)path
{
    if (!path) { return nil; }
    NSURL *url = [NSURL fileURLWithPath:path];
    SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:url];
    if (!metadata) { return nil; }
    NSString *title = metadata.title;
    NSString *albumTitle = metadata.albumTitle;
    NSString *artistName = metadata.artist;
    NSString *albumArtistName = metadata.albumArtist;
    return [self songsWithName:title albumName:albumTitle artistName:albumArtistName ?: artistName];
}


- (NSArray*)objectsWithIDs:(NSArray*)ids
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[ids count]];
    for (NSManagedObjectID *objectID in ids) {
        NSManagedObject *object = [self existingObjectWithID:objectID error:nil];
        if (object) { [objects addObject:object]; }
    }
    return objects;
}

- (NSArray*)objectsWithURLs:(NSArray*)urls
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[urls count]];
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    for (NSURL *url in urls) {
        NSManagedObjectID *objectID = [coordinator managedObjectIDForURIRepresentation:url];
        if (objectID) {
            NSManagedObject *object = [self existingObjectWithID:objectID error:nil];
            if (object) { [objects addObject:object]; }
        }
    }
    return objects;
}

- (NSArray*)objectsWithURLStrings:(NSArray*)strings
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[strings count]];
    NSPersistentStoreCoordinator *coordinator = self.persistentStoreCoordinator;
    for (NSString *string in strings) {
        NSManagedObjectID *objectID = [coordinator managedObjectIDForURIRepresentation:[NSURL URLWithString:string]];
        if (objectID) {
            NSManagedObject *object = [self existingObjectWithID:objectID error:nil];
            if (object) { [objects addObject:object]; }
        }
    }
    return objects;
}

- (NSUInteger)numberOfMixes
{
    NSFetchRequest *mixesRequest = [[NSFetchRequest alloc] init];
    mixesRequest.entity = [NSEntityDescription entityForName:kEntityNameMix inManagedObjectContext:self];
    mixesRequest.resultType = NSCountResultType;
    NSError *error = nil;
    NSUInteger mixesCount = [self countForFetchRequest:mixesRequest error:&error];
    if (error) { NSLog(@"Unresolved error %@ %@", error, [error userInfo]); }
    return mixesCount;
}
@end
