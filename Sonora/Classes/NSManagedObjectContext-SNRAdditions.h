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
