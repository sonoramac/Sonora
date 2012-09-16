//
//  SNRFileImportOperation.m
//  Sonora
//
//  Created by Indragie Karunaratne on 11-11-18.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRFileImportOperation.h"
#import "SNRAudioMetadata.h"
#import "SNRSong.h"

#import "NSFileManager-SNRAdditions.h"
#import "NSUserDefaults-SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"
#import "NSString-SNRAdditions.h"

static NSString* const kFolderArtworkFileName = @"folder.jpg";

#define kImportSaveEvery 500

@interface SNRFileImportOperation ()
+ (NSArray*)filteredFileArrayForFiles:(NSArray*)files;

- (BOOL)importMetadataForSong:(SNRSong*)song atPath:(NSString*)path;
- (SNRSong*)importFileAtPath:(NSString*)path copy:(BOOL)copy;

- (NSString*)sonoraLibraryFolderPath;
- (NSString*)copyPathForSong:(SNRSong*)song originalPath:(NSString*)path;

- (void)backgroundContextDidSave:(NSNotification *)notification;

- (void)delegateFileImportedAtPath:(NSDictionary*)dictionary;
- (void)delegateDidFinishImport:(NSArray*)objectIDs;
- (void)delegateWillBeginImport;
@end

@implementation SNRFileImportOperation {
    NSArray *_files;
    NSManagedObjectContext *_backgroundContext;
}
@synthesize delegate = _delegate;
@synthesize files = _files;
@synthesize play = _play;

#pragma mark - Initialization

- (id)initWithFiles:(NSArray*)files
{
    if ((self = [super init])) {
        _files = [[self class] filteredFileArrayForFiles:files];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)main
{
    if (![_files count]) { return; }
    if ([self.delegate respondsToSelector:@selector(fileImportOperation:willBeginImporting:)]) {
        [self performSelectorOnMainThread:@selector(delegateWillBeginImport) withObject:nil waitUntilDone:YES];
    }
    NSPersistentStoreCoordinator *coordinator = [SONORA_MANAGED_OBJECT_CONTEXT persistentStoreCoordinator];
    NSUInteger saveCount = 0;
    _backgroundContext = [[NSManagedObjectContext alloc] init];
    [_backgroundContext setUndoManager:nil];
    [_backgroundContext setPersistentStoreCoordinator:coordinator];
    [_backgroundContext setMergePolicy:[[NSMergePolicy alloc] initWithMergeType:NSOverwriteMergePolicyType]];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(backgroundContextDidSave:) name:NSManagedObjectContextDidSaveNotification object:_backgroundContext];
    NSDate *currentDate = [NSDate date];
    NSMutableArray *songs = [NSMutableArray array];
    BOOL copyMusic = [[NSUserDefaults standardUserDefaults] copyMusic];
    for (NSString *path in _files) {
        @autoreleasepool {
            SNRSong *song = [self importFileAtPath:path copy:copyMusic];
            if (song) {
                [songs addObject:song];
                song.dateAdded = currentDate;
                saveCount++;
            }
            if (saveCount == kImportSaveEvery) { // save every X songs
                saveCount = 0;
                [_backgroundContext saveChanges];
            }
        }
    }
    if (saveCount != 0) {
        [_backgroundContext saveChanges];
    }
    if ([self.delegate respondsToSelector:@selector(fileImportOperationDidFinishImport:withObjectIDs:)]) {
        [self performSelectorOnMainThread:@selector(delegateDidFinishImport:) withObject:[songs valueForKey:@"objectID"] waitUntilDone:YES];
    }
}

#pragma mark - Importing

- (SNRSong*)importFileAtPath:(NSString*)path copy:(BOOL)copy;
{
    SNRSong *song = [_backgroundContext createObjectOfEntityName:kEntityNameSong];
    NSString *copyPath = nil;
    if ([self importMetadataForSong:song atPath:path]) {
        if (copy) {
            copyPath = [self copyPathForSong:song originalPath:path];
        } else {
            [song setBookmarkWithPath:path];
        }
    } else {
        [song deleteFromLibraryAndFromDisk:NO];
        song = nil;
    }
    if (song && copyPath) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] copyItemAtPath:path toPath:copyPath error:&error]) {
            NSLog(@"Failed to copy song at path %@: %@, %@", path, error, [error userInfo]);
            [song deleteFromLibraryAndFromDisk:NO];
            song = nil;
        } else {
            [song setBookmarkWithPath:copyPath];
        }
    }
    if ([self.delegate respondsToSelector:@selector(fileImportOperation:importedFileAtPath:success:)]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:path, @"path", [NSNumber numberWithBool:song != nil], @"success", nil];
        [self performSelectorOnMainThread:@selector(delegateFileImportedAtPath:) withObject:dict waitUntilDone:YES];
    }
    return song;
}

- (BOOL)importMetadataForSong:(SNRSong*)song atPath:(NSString*)path
{
    NSLog(@"Attempting to import song at path: %@", path);
    SNRAudioMetadata *metadata = [[SNRAudioMetadata alloc] initWithFileAtURL:[NSURL fileURLWithPath:path]];
    if (!metadata) { return NO; }
    NSString *title = metadata.title;
    song.name = ([title length] != 0) ? title : NSLocalizedString(@"UntitledSong", nil);
    song.composer = metadata.composer;
    song.compilation = metadata.compilation;
    song.year = [NSNumber numberWithInteger:[metadata.releaseDate integerValue]];
    song.rawAlbumArtist = metadata.albumArtist;
    song.rawArtist = metadata.artist;
    song.trackTotal = metadata.trackTotal;
    song.trackNumber = metadata.trackNumber;
    song.discNumber = metadata.discNumber;
    song.discTotal = metadata.discTotal;
    song.duration = metadata.duration;
    song.lyrics = metadata.lyrics;
    NSNumber *trackTotal = metadata.trackTotal;
    NSNumber *trackNumber = metadata.trackNumber;
    NSNumber *discNumber = metadata.discNumber;
    NSNumber *discTotal = metadata.discTotal;
    if (trackTotal.integerValue) { song.trackTotal = trackTotal; }
    if (trackNumber.integerValue) { song.trackNumber = trackNumber; }
    if (discNumber.integerValue) { song.discNumber = discNumber; }
    if (discTotal.integerValue) { song.discTotal = discTotal; }
    NSString *albumTitle = metadata.albumTitle;
    NSManagedObjectContext *ctx = song.managedObjectContext;
    NSString *artistName = ([song.rawAlbumArtist length] != 0) ? song.rawAlbumArtist : song.rawArtist;
    SNRArtist *artist = [song.compilation boolValue] ? [ctx compilationsArtist] :  [ctx artistWithName:artistName create:YES];
    song.album = [ctx albumWithName:albumTitle byArtist:artist create:YES];
    song.album.dateModified = [NSDate date];
    if (!song.album.artwork) {
        NSData *coverArtData = metadata.frontCoverArtData;
        if (coverArtData) {
            [song.album setArtworkWithData:coverArtData cropped:NO];
        } else {
            NSString *folderPath = [path stringByDeletingLastPathComponent];
            NSString *jpgPath = [folderPath stringByAppendingPathComponent:kFolderArtworkFileName];
            NSData *data = [NSData dataWithContentsOfFile:jpgPath];
            if (data) {
                [song.album setArtworkWithData:data cropped:NO];
            }
        }
    }
    return YES;
}

#pragma mark - Copying

- (NSString*)copyPathForSong:(SNRSong*)song originalPath:(NSString*)path
{
    NSString *basePath = [self sonoraLibraryFolderPath];
    NSCharacterSet *characterSet = [[NSCharacterSet characterSetWithCharactersInString:@":"] invertedSet];
    NSString *artistPath = [basePath stringByAppendingPathComponent:[song.album.artist.name stringByFilteringToCharactersInSet:characterSet]];
    NSString *albumPath = [artistPath stringByAppendingPathComponent:[song.album.name stringByFilteringToCharactersInSet:characterSet]];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:albumPath]) {
        [fm createDirectoryAtPath:albumPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *extension = [[path pathExtension] lowercaseString];
    NSUInteger trackNumber = [song.trackNumber unsignedIntegerValue];
    NSString *songName = [NSString stringWithFormat:@"%lu %@.%@", trackNumber, [song.name stringByFilteringToCharactersInSet:characterSet], extension];
    NSString *copyPath = [albumPath stringByAppendingPathComponent:songName];
    return copyPath;
}

- (NSString*)sonoraLibraryFolderPath
{
    NSString *musicFolderPath = [[NSUserDefaults standardUserDefaults] libraryPath];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:musicFolderPath]) {
        NSError *error = nil;
        if (![fm createDirectoryAtPath:musicFolderPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            if (error) {
                NSAlert *errorAlert = [NSAlert alertWithError:error];
                [errorAlert runModal];
            }
            return nil;
        }
    }
    return musicFolderPath;
}

#pragma mark - Delegate

- (void)delegateFileImportedAtPath:(NSDictionary*)dictionary
{
    NSString *path = [dictionary valueForKey:@"path"];
    BOOL success = [[dictionary valueForKey:@"success"] boolValue];
    [self.delegate fileImportOperation:self importedFileAtPath:path success:success];
}

- (void)delegateDidFinishImport:(NSArray*)objectIDs
{
    [self.delegate fileImportOperationDidFinishImport:self withObjectIDs:objectIDs];
}

- (void)delegateWillBeginImport
{
    [self.delegate fileImportOperation:self willBeginImporting:[_files count]];
}

#pragma mark - File Validation

+ (BOOL)validateFiles:(NSArray*)files
{
    return [[self filteredFileArrayForFiles:files] count];
}

+ (NSArray*)filteredFileArrayForFiles:(NSArray*)files
{
    NSArray *supportedExtensions = [SNRAudioMetadata supportedFileExtensions];
    NSMutableArray *filesToImport = [NSMutableArray array];
    NSFileManager *fm = [NSFileManager defaultManager];
    for (NSString *path in files) {
        BOOL isDirectory = NO;
        NSArray *subpaths = nil;
        if ([fm fileExistsAtPath:path isDirectory:&isDirectory] && isDirectory) {
            subpaths = [fm recursiveContentsOfDirectoryAtPath:path];
        } else {
            subpaths = [NSArray arrayWithObject:path];
        }
        for (NSString *subpath in subpaths) {
            NSString *extension = [[subpath pathExtension] lowercaseString];
            if ([supportedExtensions containsObject:extension]) {
                [filesToImport addObject:subpath];
            }
        }
    }
    return filesToImport;
}

- (void)backgroundContextDidSave:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSManagedObjectContext *context = SONORA_MANAGED_OBJECT_CONTEXT;
        [context mergeChangesFromContextDidSaveNotification:notification];
        [context saveChanges];
    });
}
@end
