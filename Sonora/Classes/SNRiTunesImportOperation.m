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

#import "SNRiTunesImportOperation.h"
#import "SNRAudioMetadata.h"
#import "SNRSong.h"
#import "SNRAlbum.h"

#import "NSManagedObjectContext-SNRAdditions.h"
#import "NSUserDefaults-SNRAdditions.h"

static NSString* const kiTunesKeyTracks = @"Tracks";
static NSString* const kiTunesKeyPlaylists = @"Playlists";
static NSString* const kiTunesKeyPlaylistItems = @"Playlist Items";
static NSString* const kiTunesKeyTrackID = @"Track ID";
static NSString* const kiTunesKeyMusic = @"Music";
static NSString* const kiTunesKeyName = @"Name";
static NSString* const kiTunesKeyCompilation = @"Compilation";
static NSString* const kiTunesKeyYear = @"Year";
static NSString* const kiTunesKeyComposer = @"Composer";
static NSString* const kiTunesKeyArtist = @"Artist";
static NSString* const kiTunesKeyAlbum = @"Album";
static NSString* const kiTunesKeyAlbumArtist = @"Album Artist";
static NSString* const kiTunesKeyTrackNumber = @"Track Number";
static NSString* const kiTunesKeyTrackCount = @"Track Total";
static NSString* const kiTunesKeyDiscNumber = @"Disc Number";
static NSString* const kiTunesKeyDiscCount = @"Disc Total";
static NSString* const kiTunesKeyTotalTime = @"Total Time";
static NSString* const kiTunesKeyDateAdded = @"Date Added";
static NSString* const kiTunesKeyPersistentID = @"Persistent ID";
static NSString* const kiTunesKeyLocation = @"Location";
static NSString* const kiTunesKeyMaster = @"Master";
static NSString* const kiTunesKeyDistinguishedKind = @"Distinguished Kind";
static NSString* const kiTunesKeyPlaylistPersistentID = @"Playlist Persistent ID";
static NSString* const kiTunesKeyFolder = @"Folder";
static NSString* const kiTunesKeySmartInfo = @"Smart Info";
static NSString* const kiTunesKeyTrackType = @"Track Type";
static NSString* const kiTunesKeyValueFileTrackType = @"File";
static NSString* const kiTunesKeyHasVideo = @"Has Video";

#define kImportSaveEvery 500

@interface SNRiTunesImportOperation ()
- (NSArray*)iTunesSongs;
- (NSArray*)iTunesAddedSongs;
- (SNRSong*)importiTunesFileWithDictionary:(NSDictionary*)dict;
- (void)delegateFinishedImporting:(NSNumber*)count;
- (void)delegateWillBeginImporting:(NSNumber*)count;
- (void)delegateImportedFile:(NSDictionary*)dict;
- (void)backgroundContextDidSave:(NSNotification *)notification ;
@end

@implementation SNRiTunesImportOperation {
    NSManagedObjectContext *_backgroundContext;
    NSDictionary *_iTunesDictionary;
    NSArray *_removedPersistentIDArray;
}
@synthesize importAll = sImportAll;
@synthesize delegate = sDelegate;

+ (NSURL*)iTunesLibraryURL
{
    NSArray *libraryDatabases = [[[NSUserDefaults standardUserDefaults] persistentDomainForName:@"com.apple.iApps"] objectForKey:@"iTunesRecentDatabases"];
    return (([libraryDatabases count])) ? [NSURL URLWithString:[libraryDatabases objectAtIndex:0]] : nil;
}

- (id)init
{
    if ((self = [super init])) {
        NSURL *libraryURL = [[self class] iTunesLibraryURL];
        if (!libraryURL) { return nil; }
        NSData *data = [NSData dataWithContentsOfURL:libraryURL];
        NSError *error = nil;
        _iTunesDictionary = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:NULL error:&error];
        if (error) {
            NSLog(@"Error reading iTunes Music Library.xml: %@, %@", error, [error userInfo]);
        }
    }
    return self;
}

#pragma mark - iTunes

- (NSArray*)iTunesSongs
{
    NSArray *playlists = [_iTunesDictionary valueForKey:kiTunesKeyPlaylists];
    NSDictionary *tracks = [_iTunesDictionary valueForKey:kiTunesKeyTracks];
    NSMutableArray *songs = nil;
    for (NSDictionary *playlist in playlists) {
        NSNumber *music = [playlist valueForKey:kiTunesKeyMusic];
        if ([music boolValue]) {
            NSArray *items = [playlist valueForKey:kiTunesKeyPlaylistItems];
            songs = [NSMutableArray arrayWithCapacity:[items count]];
            for (NSDictionary *item in items) {
                NSNumber *trackID = [item valueForKey:kiTunesKeyTrackID];
                NSDictionary *track = [tracks objectForKey:trackID.stringValue];
                if (track) { [songs addObject:track]; }
            }
        }
    }
    return songs;
}

- (NSArray*)iTunesAddedSongs
{
    static NSString* persistentIDKey = @"iTunesPersistentID";
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:kEntityNameSong];
    request.resultType = NSDictionaryResultType;
    request.propertiesToFetch = [NSArray arrayWithObject:persistentIDKey];
    NSError *error = nil;
    NSArray *dicts = [_backgroundContext executeFetchRequest:request error:&error];
    if (error) { 
        NSLog(@"Unresolved error: %@ %@", error, [error userInfo]);
        return nil;
    }
    NSMutableArray *strings = [NSMutableArray arrayWithArray:[dicts valueForKey:persistentIDKey]];
    NSMutableArray *filtered = [NSMutableArray array];
    NSArray *playlists = [_iTunesDictionary valueForKey:kiTunesKeyPlaylists];
    NSDictionary *tracks = [_iTunesDictionary valueForKey:kiTunesKeyTracks];
    for (NSDictionary *playlist in playlists) {
        NSNumber *music = [playlist valueForKey:kiTunesKeyMusic];
        if ([music boolValue]) {
            NSArray *items = [playlist valueForKey:kiTunesKeyPlaylistItems];
            for (NSDictionary *item in items) {
                NSNumber *trackID = [item valueForKey:kiTunesKeyTrackID];
                NSDictionary *track = [tracks objectForKey:trackID.stringValue];
                if (![[track valueForKey:kiTunesKeyTrackType] isEqualToString:kiTunesKeyValueFileTrackType] || [[track valueForKey:kiTunesKeyHasVideo] boolValue]) {
                    continue;
                }
                NSString *persistentID = [track valueForKey:kiTunesKeyPersistentID];
                NSUInteger index = [strings indexOfObject:persistentID];
                if (persistentID) {
                    if (index == NSNotFound) {
                        [filtered addObject:track];
                    } else {
                        [strings removeObjectAtIndex:index];
                    }
                }
            }
        }
    }
    _removedPersistentIDArray = strings;
    return filtered;
}

#pragma mark - NSOperation

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)main
{
    NSPersistentStoreCoordinator *coordinator = [SONORA_MANAGED_OBJECT_CONTEXT persistentStoreCoordinator];
    _backgroundContext = [[NSManagedObjectContext alloc] init];
    [_backgroundContext setUndoManager:nil];
    [_backgroundContext setPersistentStoreCoordinator:coordinator];
    [_backgroundContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(backgroundContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:_backgroundContext];
    NSArray *songs = self.importAll ? [self iTunesSongs] : [self iTunesAddedSongs];
    if (![songs count]) { return; }
    if ([self.delegate respondsToSelector:@selector(iTunesImportOperation:willBeginImporting:)]) {
        [self performSelectorOnMainThread:@selector(delegateWillBeginImporting:) withObject:[NSNumber numberWithInteger:[songs count]] waitUntilDone:YES];
    }
    NSUInteger saveCount = 0;
    NSDate *currentDate = [NSDate date];
    NSInteger imported = 0;
    for (NSDictionary *track in songs) {
        @autoreleasepool {
            SNRSong *song = [self importiTunesFileWithDictionary:track];
            if (song) {
                NSDate *date = [track valueForKey:kiTunesKeyDateAdded];
                if (!date) { date = currentDate; }
                song.dateAdded = date;
                song.album.dateModified = (song.album.dateModified != nil) ? [song.album.dateModified laterDate:date] : date;
                imported++;
                saveCount++;
            }
            if (saveCount == kImportSaveEvery) { // save every X songs
                saveCount = 0;
                [_backgroundContext saveChanges];
                [_backgroundContext reset];
            }
        }
    }
    for (NSString *persistentID in _removedPersistentIDArray) {
        if (![persistentID isEqual:[NSNull null]]) {
            SNRSong *song = [_backgroundContext songWithiTunesPersistentID:persistentID];
            [song deleteFromLibraryAndFromDisk:NO];
            saveCount++;
        }
    }
    if ([[NSUserDefaults standardUserDefaults] synciTunesPlaylists]) {
        NSArray *playlists = [_iTunesDictionary valueForKey:kiTunesKeyPlaylists];
        NSDictionary *tracks = [_iTunesDictionary valueForKey:kiTunesKeyTracks];
        for (NSDictionary *playlist in playlists) {
            if ([playlist valueForKey:kiTunesKeyMaster] || [playlist valueForKey:kiTunesKeyDistinguishedKind] || [[playlist valueForKey:kiTunesKeyFolder] boolValue] || [playlist valueForKey:kiTunesKeySmartInfo]) {
                continue;
            }
            NSString *playlistPersistentID = [playlist valueForKey:kiTunesKeyPlaylistPersistentID];
            NSString *name = [playlist valueForKey:kiTunesKeyName];
            SNRMix *mix = [_backgroundContext mixWithiTunesPersistentID:playlistPersistentID];
            mix.name = name;
            NSArray *items = [playlist valueForKey:kiTunesKeyPlaylistItems];
            NSMutableOrderedSet *mixItems = [[NSMutableOrderedSet alloc] initWithCapacity:[items count]];
            for (NSDictionary *item in items) {
                NSNumber *trackID = [item valueForKey:kiTunesKeyTrackID];
                NSDictionary *trackDict = [tracks objectForKey:trackID.stringValue];
                NSString *persistentID = [trackDict valueForKey:kiTunesKeyPersistentID];
                SNRSong *song = [_backgroundContext songWithiTunesPersistentID:persistentID];
                if (song) { [mixItems addObject:song]; }
            }
            if (![mixItems count]) {
                [mix deleteFromContextAndSearchIndex];
            } else {
                mix.songs = mixItems;
            }
            saveCount++;
        }
    }
    if (saveCount != 0) {
        [_backgroundContext saveChanges];
        [_backgroundContext reset];
    }
    if ([self.delegate respondsToSelector:@selector(iTunesImportOperation:finishedImporting:)]) {
        [self performSelectorOnMainThread:@selector(delegateFinishedImporting:) withObject:[NSNumber numberWithInteger:imported] waitUntilDone:YES];
    }
}

- (SNRSong*)importiTunesFileWithDictionary:(NSDictionary*)dict
{
    SNRSong *song = [_backgroundContext createObjectOfEntityName:kEntityNameSong];
    NSURL *url = [NSURL URLWithString:[dict valueForKey:kiTunesKeyLocation]];
    NSString *path = [url path];
    //NSLog(@"Attempting to import song at path: %@", path);
    if (path && [song setBookmarkWithPath:path]) {
        NSString *name = [dict valueForKey:kiTunesKeyName];
        song.name = ([name length] != 0) ? name : NSLocalizedString(@"UntitledSong", nil);
        song.compilation = [dict valueForKey:kiTunesKeyCompilation];
        song.year = [dict valueForKey:kiTunesKeyYear];
        song.rawAlbumArtist = [dict valueForKey:kiTunesKeyAlbumArtist];
        song.rawArtist = [dict valueForKey:kiTunesKeyArtist];
        song.composer = [dict valueForKey:kiTunesKeyComposer];
        song.trackTotal = [dict valueForKey:kiTunesKeyTrackCount];
        song.trackNumber = [dict valueForKey:kiTunesKeyTrackNumber];
        song.discNumber = [dict valueForKey:kiTunesKeyDiscNumber];
        song.discTotal = [dict valueForKey:kiTunesKeyDiscCount];
        NSNumber *trackTotal = [dict valueForKey:kiTunesKeyTrackCount];
        NSNumber *trackNumber = [dict valueForKey:kiTunesKeyTrackNumber];
        NSNumber *discNumber = [dict valueForKey:kiTunesKeyDiscNumber];
        NSNumber *discTotal = [dict valueForKey:kiTunesKeyDiscCount];
        if (trackTotal.integerValue) { song.trackTotal = trackTotal; }
        if (trackNumber.integerValue) { song.trackNumber = trackNumber; }
        if (discNumber.integerValue) { song.discNumber = discNumber; }
        if (discTotal.integerValue) { song.discTotal = discTotal; }
        NSNumber *duration = [dict valueForKey:kiTunesKeyTotalTime];
        song.duration = [NSNumber numberWithInteger:[duration integerValue]/1000]; // Time in iTunes is in milliseconds, covert to seconds
        song.iTunesPersistentID = [dict valueForKey:kiTunesKeyPersistentID];
        NSString *albumTitle = [dict valueForKey:kiTunesKeyAlbum];
        NSString *artistName = ([song.rawAlbumArtist length] != 0) ? song.rawAlbumArtist : song.rawArtist;
        SNRArtist *artist = [song.compilation boolValue] ? [_backgroundContext compilationsArtist] :  [_backgroundContext artistWithName:artistName create:YES];
        song.album = [_backgroundContext albumWithName:albumTitle byArtist:artist create:YES];
        if (!song.album.artwork) {
            SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:url];
            NSData *art = metadata.frontCoverArtData;
            if (art) { [song.album setArtworkWithData:art cropped:NO]; }
        }
    } else {
        [song deleteFromLibraryAndFromDisk:NO];;
        song = nil;
    }
    if ([self.delegate respondsToSelector:@selector(iTunesImportOperation:importedFile:success:)]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:path, @"path", [NSNumber numberWithBool:song != nil], @"success", nil];
        [self performSelectorOnMainThread:@selector(delegateImportedFile:) withObject:dict waitUntilDone:YES];
    }
    return song;
}

#pragma mark - Delegate

- (void)delegateFinishedImporting:(NSNumber*)count
{
    [self.delegate iTunesImportOperation:self finishedImporting:[count integerValue]];
}

- (void)delegateWillBeginImporting:(NSNumber*)count
{
    [self.delegate iTunesImportOperation:self willBeginImporting:[count integerValue]];
}

- (void)delegateImportedFile:(NSDictionary*)dict
{
    NSString *path = [dict valueForKey:@"path"];
    BOOL success = [[dict valueForKey:@"success"] boolValue];
    [self.delegate iTunesImportOperation:self importedFile:path success:success];
}

- (void)backgroundContextDidSave:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = SONORA_MANAGED_OBJECT_CONTEXT;
        [context mergeChangesFromContextDidSaveNotification:notification];
        [context saveChanges];
    });
}
@end
