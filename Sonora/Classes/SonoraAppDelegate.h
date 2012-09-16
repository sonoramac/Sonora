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
