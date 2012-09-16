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
#import "SonoraAppDelegate.h"
#import "SNRArtistsViewController.h"
#import "SNRAlbumsViewController.h"
#import "SNRSearchIndex.h"
#import "SNRAudioMetadata.h"
#import "SNRURLHandler.h"
#import "SNRPreferencesWindowController.h"
#import "SNRHotKeyManager.h"
#import "SNRLastFMEngine.h"
#import "SNRQueueCoordinator.h"
#import "SNRMetadataWindowController.h"
#import "SNRAboutWindowController.h"
#import "SNRSearchPopoverController.h"
#import "SNRImportManager.h"
#import "SNRSong.h"

#import "NSUserDefaults-SNRAdditions.h"
#import "NSManagedObjectContext-SNRAdditions.h"
#import "NSMenu+SNRAdditions.h"

#import "SNRArtwork.h"

static NSString* const kPersistentStoreFilename = @"library";
static NSString* const kSearchIndexFilename = @"searchindex";
static NSString* const kLibraryContainerFilename = @"Library.sndb";
static NSString* const kBookmarksFilename = @"bookmarks.plist";
static NSString* const kMusicFolderName = @"Music";

static NSString* const kBookmarksiTunesKey = @"iTunes";
static NSString* const kBookmarksSonoraKey = @"Sonora";

static NSString* const kiTunesAppPath = @"/Applications/iTunes.app";

@interface SonoraAppDelegate ()

@property (nonatomic, retain) IBOutlet NSView *toolbarView;
// Setup
- (void)showImportSheet;
- (void)openOrImportFiles:(NSArray*)files;
@property (nonatomic, retain) NSArray *queuedImport;
@property (nonatomic, retain) NSMutableArray *queuedPlays;
@end

@implementation SonoraAppDelegate {
    BOOL _hasLaunched;
}

@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;

@synthesize uiController = _uiController;
@synthesize URLHandler = _URLHandler;
@synthesize queueCoordinator = _queueCoordinator;
@synthesize queuedImport = _queuedImport;
@synthesize queuedPlays = _queuedPlays;

@synthesize searchField = _searchField;
@synthesize shareButton = _shareButton;
@synthesize window = _window;
@synthesize toolbarView = _toolbarView;
@synthesize progressBar = _progressBar;

@synthesize blockTermination = _blockTermination;
@synthesize artistsViewController = _artistsViewController;
@synthesize albumsViewController = _albumsViewController;

#pragma mark - Application delegate

+ (void)initialize {
    // Load the defaults from the plist
	NSString *defaultsFilename = [[NSBundle mainBundle] pathForResource:@"Sonora-Defaults" ofType:@"plist"];
	NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithContentsOfFile:defaultsFilename];
    [defaults setObject:[[self defaultMusicDirectory] path] forKey:@"libraryPath"];
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _hasLaunched = YES;
    // Register the URL handler to handle the Sonora URL scheme
    _URLHandler = [SNRURLHandler new];
    [_URLHandler registerURLHandlers];
    
    // Register all the global hotkeys
    [[SNRHotKeyManager sharedManager] registerHotKeys];
    [[SNRLastFMEngine sharedInstance] setUsername:[[NSUserDefaults standardUserDefaults] lastFMUsername]];
    
    // Set up Growl and the Last.fm engine
    [GrowlApplicationBridge setGrowlDelegate:self];
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    // Configure the UI
    // Reload the artists view controller
    [self.artistsViewController reloadData];
    // This is an ugly hack to instantiate the metadata window and have it receive
    // notifications. Fix this later.
    [[SNRMetadataWindowController sharedWindowController] window];
    // Connect outlets to the shared search popover controller
    SNRSearchPopoverController *popoverController = [SNRSearchPopoverController sharedPopoverController];
    popoverController.searchViewController.searchField = self.searchField;
    self.searchField.delegate = popoverController.searchViewController;
    if (SNR_RunningMountainLion) {
        [self.shareButton setHidden:NO];
    }
    [self.shareButton sendActionOn:NSLeftMouseDownMask];
    // Connect the progress bar to the import manager
    [[SNRImportManager sharedImportManager] setProgressBar:self.progressBar];
    // If there's a queued import that needs to be run, run it now
    if (self.queuedImport) {
        [self openOrImportFiles:self.queuedImport];
        self.queuedImport = nil;
    }
    // Check to see if the search index exists
    // It's assumed that if there's no index, the library needs to be reimported
    // We need a more robusy way of checking to see if an import has been run
    NSURL *searchURL = [[self applicationFilesDirectory] URLByAppendingPathComponent:kSearchIndexFilename];
    BOOL indexExists = [[NSFileManager defaultManager] fileExistsAtPath:searchURL.path];
    
    // Create the search index
    SNRSearchIndex *index = [[SNRSearchIndex alloc] initByOpeningSearchIndexAtURL:searchURL persistentStoreCoordinator:[self persistentStoreCoordinator]];
    if (!index) {
        index = [[SNRSearchIndex alloc] initByCreatingSearchIndexAtURL:searchURL persistentStoreCoordinator:[self persistentStoreCoordinator]];
    }
    [SNRSearchIndex setSharedIndex:index];
    
    if (!indexExists) {
        [self showImportSheet];
    } else if (ud.synciTunesSongs) {
        [[SNRImportManager sharedImportManager] performiTunesSync];
    }
}

- (void)showMainApplicationWindow
{
    [self.window makeKeyAndOrderFront:nil];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    [self application:theApplication openFiles:[NSArray arrayWithObject:filename]];
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames
{
    if (_hasLaunched) {
        [self openOrImportFiles:filenames];
    } else {
        self.queuedImport = filenames;
    }
}
- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication hasVisibleWindows:(BOOL)flag
{
    [self.window makeKeyAndOrderFront:nil];
    [NSApp activateIgnoringOtherApps:YES];
    return YES;
}

- (NSMenu*)applicationDockMenu:(NSApplication *)sender
{
    NSMenu *menu = [[NSMenu alloc] initWithTitle:@"Dock"];
    [self.queueCoordinator menuNeedsUpdate:menu];
    return menu;
}

- (void)setSonoraLibraryURL:(NSURL*)libraryURL
{
    NSURL *bookmarksPath = [[self applicationSupportDirectory] URLByAppendingPathComponent:kBookmarksFilename];
    NSError *error = nil;
    NSData *libraryBookmark = [libraryURL bookmarkDataWithOptions:NSURLBookmarkCreationMinimalBookmark includingResourceValuesForKeys:nil relativeToURL:nil error:&error];
    if (error) { NSLog(@"Error creating bookmark for Sonora library: %@, %@", error, [error userInfo]); }
    if (libraryBookmark) {
        [[NSDictionary dictionaryWithObject:libraryBookmark forKey:kBookmarksSonoraKey] writeToURL:bookmarksPath atomically:YES];
    }
    [[NSUserDefaults standardUserDefaults] setLibraryPath:[libraryURL path]];
}

#pragma mark - Importing

- (void)openOrImportFiles:(NSArray*)files
{
    NSMutableArray *play = [NSMutableArray array];
    NSMutableArray *import = [NSMutableArray array];
    for (NSString *file in files) {
        NSArray *songs = [self.managedObjectContext songsAtSourcePath:file];
        if ([songs count]) {
            [play addObject:[songs objectAtIndex:0]];
        } else {
            [import addObject:file];
        }
    }
    if ([play count]) {
        [SNR_MainQueueController playSongs:play];
    }
    if ([import count]) {
        [[SNRImportManager sharedImportManager] importFiles:import play:YES];
    }
}

- (void)showImportSheet
{
    [[SNRRestorationManager sharedManager] deleteRestorationState];
    NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"ImportiTunesTitle", nil) defaultButton:NSLocalizedString(@"ImportiTunesDefaultButton", nil) alternateButton:NSLocalizedString(@"ImportiTunesAlternateButton", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"ImportiTunesMessage", nil)];
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:kiTunesAppPath];
    [alert setIcon:icon];
    [alert beginSheetModalForWindow:[self window] modalDelegate:self didEndSelector:@selector(importAlertDidEnd:returnCode:contextInfo:) contextInfo:NULL];
    
}

- (void)importAlertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo
{
    BOOL defaultReturn = returnCode == NSAlertDefaultReturn;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setSynciTunesSongs:defaultReturn];
    [ud setSynciTunesPlaylists:defaultReturn];
    if (defaultReturn) {
        [[SNRImportManager sharedImportManager] performiTunesSync];
    }
}

#pragma mark - Growl Delegate

- (NSDictionary *)registrationDictionaryForGrowl
{
    NSArray *all = [NSArray arrayWithObjects:kGrowlNotificationNowPlaying, kGrowlNotificationImportediTunesTracks, kGrowlNotificationLovedTrack, nil];
    NSArray *def = [NSArray arrayWithObjects:kGrowlNotificationNowPlaying, kGrowlNotificationImportediTunesTracks, kGrowlNotificationLovedTrack, nil];
    NSDictionary *human = [NSDictionary dictionaryWithObjectsAndKeys:NSLocalizedString(kGrowlNotificationNowPlaying, nil), kGrowlNotificationNowPlaying, NSLocalizedString(kGrowlNotificationImportediTunesTracks, nil), kGrowlNotificationImportediTunesTracks, NSLocalizedString(kGrowlNotificationLovedTrack, nil), kGrowlNotificationLovedTrack, nil];
    return [NSDictionary dictionaryWithObjectsAndKeys:all, GROWL_NOTIFICATIONS_ALL, def, GROWL_NOTIFICATIONS_DEFAULT, human, GROWL_NOTIFICATIONS_HUMAN_READABLE_NAMES, nil];
}

- (void) growlNotificationWasClicked:(id)clickContext
{
    [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark - Menu Items

- (IBAction)iTunesSync:(id)sender
{
    [[SNRImportManager sharedImportManager] performiTunesSync];
}

- (IBAction)search:(id)sender
{
    [self.window makeFirstResponder:self.searchField];
}

- (IBAction)preferences:(id)sender
{
    [[SNRPreferencesWindowController sharedPrefsWindowController] showWindow:nil];
}

- (IBAction)feedback:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"mailto:support@getsonora.com"]];
}

- (IBAction)website:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://getsonora.com"]];
}

- (IBAction)buy:(id)sender
{
    [sender setState:NSOnState];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/sonora/id504100102?mt=12"]];
}

- (IBAction)help:(id)sender
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://getsonora.com/support/"]];
}

- (IBAction)open:(id)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.canChooseDirectories = NO;
    panel.resolvesAliases = NO;
    panel.allowsMultipleSelection = YES;
    panel.allowedFileTypes = [SNRAudioMetadata supportedFileExtensions];
    NSInteger response = [panel runModal];
    if (response == NSOKButton) {
        NSArray *URLs = panel.URLs;
        NSArray *filenames = [URLs valueForKey:@"path"];
        [self application:NSApp openFiles:filenames];
    }
}

- (IBAction)editMetadata:(id)sender
{
    SNRMetadataWindowController *metadata = [SNRMetadataWindowController sharedWindowController];
    [metadata.window isVisible] ? [metadata hideWindow:nil] : [metadata showWindow:nil];
}

- (IBAction)share:(id)sender
{
    SNRSong *song = [[self.queueCoordinator activeQueueController] currentSong];
    if (song) {
#if SONORA_COMPILING_ML
        NSString *nowPlaying = [NSString stringWithFormat:@"♫ %@ - %@ ♫", song.name, song.displayArtistName];
        NSSharingServicePicker *picker = [[NSSharingServicePicker alloc] initWithItems:[NSArray arrayWithObject:nowPlaying]];
        [picker showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
#endif
    } else {
        NSMenu *share = [[NSMenu alloc] initWithTitle:@"Share"];
        [share addItemWithTitle:NSLocalizedString(@"NothingPlaying", nil) action:nil keyEquivalent:@""];
        [share popupFromView:sender];
    }
}

/**
 Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Sonora" in the user's Library directory.
 */

+ (NSURL *)sonoraDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSMusicDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString *sonoraPath = [basePath stringByAppendingPathComponent:@"Sonora"];
    return [NSURL fileURLWithPath:sonoraPath];
}

+ (NSURL *)defaultMusicDirectory
{
    return [[self sonoraDirectory] URLByAppendingPathComponent:kMusicFolderName];
}

- (NSURL*)applicationFilesDirectory
{
    NSURL *libraryPath = [[[self class] sonoraDirectory] URLByAppendingPathComponent:kLibraryContainerFilename];
    return [libraryPath URLByAppendingPathComponent:@"Contents"];
}

- (NSURL *)applicationSupportDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    NSString *path = [basePath stringByAppendingPathComponent:@"Sonora"];
    NSFileManager *fm = [NSFileManager defaultManager];
    if (![fm fileExistsAtPath:path isDirectory:NULL]) {
        [fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return [NSURL fileURLWithPath:path];
}

/**
 Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Sonora" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:kPersistentStoreFilename];
    NSURL *searchURL = [applicationFilesDirectory URLByAppendingPathComponent:kSearchIndexFilename];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
        NSAlert *alert = [NSAlert alertWithMessageText:NSLocalizedString(@"IncompatibleLibraryTitle", nil) defaultButton:NSLocalizedString(@"IncompatibleLibraryDefaultButton", nil) alternateButton:NSLocalizedString(@"IncompatibleLibraryAlternateButton", nil) otherButton:nil informativeTextWithFormat:NSLocalizedString(@"IncompatibleLibraryMessage", nil)];
        [alert setAlertStyle:NSWarningAlertStyle];
        NSInteger result = [alert runModal];
        if (result == NSAlertDefaultReturn) {
            [fileManager removeItemAtURL:url error:nil];
            [fileManager removeItemAtURL:searchURL error:nil];
            [fileManager removeItemAtURL:[self applicationSupportDirectory] error:nil];
            [self showImportSheet];
            __persistentStoreCoordinator = nil;
            return __persistentStoreCoordinator;
        } else {
            [NSApp terminate:nil];
        }
        __persistentStoreCoordinator = nil;
        return nil;
    }
    return __persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    [__managedObjectContext setUndoManager:nil];
    
    return __managedObjectContext;
}

/**
 Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
 Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if (self.blockTermination) {
        return NSTerminateCancel;
    }
    if (!__managedObjectContext) {
        return NSTerminateNow;
    }
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    if (![[self managedObjectContext] saveChanges]) {
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    return NSTerminateNow;
}
#pragma mark - Scriptability

- (BOOL)application:(NSApplication*)sender delegateHandlesKey:(NSString*)key
{
    static NSSet *scriptingKeys = nil;
    if (!scriptingKeys) {
        scriptingKeys = [NSSet setWithObjects:@"playerState", @"playerVolume", @"repeatState", @"currentTime", @"totalTime", @"artist", @"albumArtist", @"track", @"album", @"jpegArtworkData", @"uniqueID", @"tiffArtworkData", @"artworkImage", nil];
    }
	return [scriptingKeys containsObject:key];
}

- (NSString *)uniqueID
{
    return [[[[[self.queueCoordinator activeQueueController] currentSong] objectID] URIRepresentation] absoluteString];
}

- (NSNumber *)playerState
{
    return [NSNumber numberWithInt:[[self.queueCoordinator activeQueueController] playerState]];
}

- (NSNumber *)playerVolume
{
    return [NSNumber numberWithFloat:[[NSUserDefaults standardUserDefaults] volume]];
}

- (void)setPlayerVolume:(NSNumber *)volume
{
    [[NSUserDefaults standardUserDefaults] setVolume:[volume floatValue]];
}

- (NSNumber *)repeatState
{
    return [NSNumber numberWithInteger:[[NSUserDefaults standardUserDefaults] repeatMode]];
}

- (void)setRepeatState:(NSNumber *)repeatState
{
    [[NSUserDefaults standardUserDefaults] setRepeatMode:[repeatState integerValue]];
}

- (NSNumber *)currentTime
{
    return [NSNumber numberWithDouble:[[self.queueCoordinator activeQueueController] currentPlaybackTime]];
}

- (void)setCurrentTime:(NSNumber *)currentTime
{
    [[self.queueCoordinator activeQueueController] seekToTime:[currentTime doubleValue]];
}

- (NSNumber *)totalTime
{
    return [NSNumber numberWithDouble:[[self.queueCoordinator activeQueueController] totalPlaybackTime]];
}

- (NSString *)artist
{
    SNRSong *song = [[self.queueCoordinator activeQueueController] currentSong];
    return song.rawArtist ?: song.rawAlbumArtist;
}

- (NSString *)albumArtist
{
    SNRSong *song = [[self.queueCoordinator activeQueueController] currentSong];
    return song.rawAlbumArtist ?: song.rawArtist;
}

- (NSString *)track
{
    return [[[self.queueCoordinator activeQueueController] currentSong] name];
}

- (NSString *)album
{
    return [[[[self.queueCoordinator activeQueueController] currentSong] album] name];
}

- (NSData *)jpegArtworkData
{
    return [[[[[self.queueCoordinator activeQueueController] currentSong] album] artwork] data];
}

- (NSData *)tiffArtworkData
{
    NSData *artworkData = [self jpegArtworkData];
    if (artworkData) {
        NSBitmapImageRep *imageRep = [NSBitmapImageRep imageRepWithData:artworkData];
        return [imageRep TIFFRepresentation];
    }
    return nil;
}

- (NSImage *)artworkImage
{
    NSData *artworkData = [self jpegArtworkData];
    if (artworkData) {
        return [[NSImage alloc] initWithData:artworkData];
    }
    return nil;
}
@end

@implementation NSImage (ImageScriptAdditions)

+ (id)scriptingImageWithDescriptor:(NSAppleEventDescriptor *)descriptor
{
    NSImage *image = nil;
    if (!([descriptor descriptorType] == typeType && [descriptor typeCodeValue] == cMissingValue)) {
		if ([descriptor descriptorType] != typeTIFF) {
			descriptor = [descriptor coerceToDescriptorType:typeTIFF];
		}
		if (descriptor != nil) {
			image = [[NSImage alloc] initWithData:[descriptor data]];
		}
	}
    return image;
}

- (id)scriptingImageDescriptor
{
	return [NSAppleEventDescriptor descriptorWithDescriptorType:typeTIFF data:[self TIFFRepresentation]];
}
@end

@implementation NSData (JpegImageDataScriptAdditions)
+ (id)scriptingJpegImageDataWithDescriptor:(NSAppleEventDescriptor *)descriptor
{
	NSData *result = nil;
	if (!([descriptor descriptorType] == typeType && [descriptor typeCodeValue] == cMissingValue)) {
		if ([descriptor descriptorType] != typeJPEG) {
			descriptor = [descriptor coerceToDescriptorType:typeJPEG];
		}
		if (descriptor != nil) {
			result = [descriptor data];
		}
	}
	return result;
}

- (id)scriptingJpegImageDataDescriptor
{
	return [NSAppleEventDescriptor descriptorWithDescriptorType:typeJPEG data:self];
}
@end

@implementation NSData (TiffImageDataScriptAdditions)
+ (id)scriptingTiffImageDataWithDescriptor:(NSAppleEventDescriptor *)descriptor
{
	NSData *result = nil;
	if (! ([descriptor descriptorType] == typeType && [descriptor typeCodeValue] == cMissingValue)) {
		if ([descriptor descriptorType] != typeTIFF) {
			descriptor = [descriptor coerceToDescriptorType:typeTIFF];
		}
		if (descriptor != nil) {
			result = [descriptor data];
		}
	}
	return result;
}

- (id)scriptingTiffImageDataDescriptor
{
	return [NSAppleEventDescriptor descriptorWithDescriptorType:typeTIFF data:self];
}
@end

@interface SNRASPauseCommand : NSScriptCommand
@end
@interface SNRASPlayCommand : NSScriptCommand
@end
@interface SNRASPlayPauseCommand : NSScriptCommand
@end
@interface SNRASStopCommand : NSScriptCommand
@end
@interface SNRASNextCommand : NSScriptCommand
@end
@interface SNRASPreviousCommand : NSScriptCommand
@end
@interface SNRASShuffleCommand : NSScriptCommand
@end

@implementation SNRASPauseCommand
- (id)performDefaultImplementation
{
    [[SNR_QueueCoordinator activeQueueController] pause];
    return nil;
}
@end

@implementation SNRASPlayCommand
- (id)performDefaultImplementation
{
    [[SNR_QueueCoordinator activeQueueController] play];
    return nil;
}
@end

@implementation SNRASPlayPauseCommand
- (id)performDefaultImplementation
{
    [[SNR_QueueCoordinator activeQueueController] playPause];
    return nil;
}
@end

@implementation SNRASStopCommand
- (id)performDefaultImplementation
{
    [[SNR_QueueCoordinator activeQueueController] clearQueueImmediately:YES];
    return nil;
}
@end

@implementation SNRASNextCommand
- (id)performDefaultImplementation
{
    [[SNR_QueueCoordinator activeQueueController] next];
    return nil;
}
@end

@implementation SNRASPreviousCommand
- (id)performDefaultImplementation
{
    [[SNR_QueueCoordinator activeQueueController] previous];
    return nil;
}
@end

@implementation SNRASShuffleCommand
- (id)performDefaultImplementation
{
    [[SNR_QueueCoordinator activeQueueController] shuffle];
    return nil;
}
@end