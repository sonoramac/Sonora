//
//  NSManagedObjectContext-SNRAdditions.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-29.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtist.h"
#import "SNRAlbum.h"
#import "SNRMix.h"
#import "SNRSong.h"

extern NSString* const kCompilationsArtistName;

@interface NSManagedObjectContext (SNRAdditions)
#pragma mark - General Convenience
- (BOOL)saveChanges;
- (id)createObjectOfEntityName:(NSString*)entityName;
- (BOOL)deleteObjects:(NSArray*)objects ofEntity:(NSString*)entity;
- (NSArray*)fetchObjectsOfEntity:(NSString*)entity sortDescriptors:(NSArray*)descriptors predicate:(NSPredicate*)predicate batchSize:(NSUInteger)batchSize fetchLimit:(NSUInteger)limit relationshipKeyPathsForPrefetching:(NSArray*)keypaths;

#pragma mark - Artists

- (SNRArtist*)artistWithName:(NSString*)name create:(BOOL)create;
- (SNRArtist*)compilationsArtist;

#pragma mark - Albums

- (SNRAlbum*)albumWithName:(NSString*)name byArtist:(SNRArtist*)artist create:(BOOL)create;

#pragma mark - Mixes

- (SNRMix*)mixWithiTunesPersistentID:(NSString*)iTunesPersistentID;
- (NSUInteger)numberOfMixes;

#pragma mark - Songs

- (SNRSong*)songWithiTunesPersistentID:(NSString*)iTunesPersistentID;
- (NSArray*)songsWithName:(NSString*)name albumName:(NSString*)albumName artistName:(NSString*)artistName;
- (NSArray*)songsAtSourcePath:(NSString*)path;

#pragma mark - Object Conversions

- (NSArray*)objectsWithIDs:(NSArray*)ids;
- (NSArray*)objectsWithURLs:(NSArray*)urls;
- (NSArray*)objectsWithURLStrings:(NSArray*)strings;
@end
