//
//  SonoraAppDelegate.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-05-21.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import <Growl/Growl.h>

@class SNRArtistsViewController;
@class SNRAlbumsViewController;
@class SNRQueueCoordinator;
@class SNRURLHandler;
@class SNRUIController;
@class SNRMetadataWindowController;

@interface SonoraAppDelegate : NSObject <NSApplicationDelegate, GrowlApplicationBridgeDelegate>
@property (nonatomic, assign) IBOutlet NSWindow *window;

// Controllers
@property (nonatomic, retain) IBOutlet SNRQueueCoordinator *queueCoordinator;
@property (nonatomic, retain) IBOutlet SNRUIController *uiController;
@property (nonatomic, retain) SNRURLHandler *URLHandler;
@property (nonatomic, retain) IBOutlet SNRArtistsViewController *artistsViewController;
@property (nonatomic, retain) IBOutlet SNRAlbumsViewController *albumsViewController;

// User Interface
@property (nonatomic, weak) IBOutlet NSSearchField *searchField;
@property (nonatomic, weak) IBOutlet NSProgressIndicator *progressBar;
@property (nonatomic, weak) IBOutlet NSButton *shareButton;

// Core Data
@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

// Application
@property (nonatomic, assign) BOOL blockTermination;
// File Locations
- (NSURL *)applicationSupportDirectory;
- (NSURL *)applicationFilesDirectory;
+ (NSURL *)sonoraDirectory;
+ (NSURL *)defaultMusicDirectory;
- (void)setSonoraLibraryURL:(NSURL*)libraryURL;

// Menu Item Actions
- (IBAction)saveAction:(id)sender;
- (IBAction)open:(id)sender;
- (IBAction)feedback:(id)sender;
- (IBAction)website:(id)sender;
- (IBAction)preferences:(id)sender;
- (IBAction)search:(id)sender;
- (IBAction)editMetadata:(id)sender;
- (IBAction)help:(id)sender;
- (IBAction)buy:(id)sender;
- (IBAction)iTunesSync:(id)sender;
- (IBAction)share:(id)sender;
@end
