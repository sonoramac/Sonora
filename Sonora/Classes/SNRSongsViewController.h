//
//  SNRSongsViewController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-04.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

@class SNRArrayController;
@class SNRAlbum;
@interface SNRSongsViewController : NSViewController <NSPopoverDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, weak) IBOutlet NSTableView *tableView;
@property (nonatomic, weak) IBOutlet SNRArrayController *arrayController;
@property (nonatomic, weak) NSPopover *popover;
- (id)initWithContainer:(id)container;

#pragma mark - Layout
+ (NSSize)sizeForContainer:(id)container;

#pragma mark - Playback
- (IBAction)enqueue:(id)sender;
- (IBAction)shuffle:(id)sender;

#pragma mark - Metadata Editing
- (IBAction)edit:(id)sender;
- (IBAction)editedTrackName:(id)sender;
- (IBAction)editedTrackNumber:(id)sender;
- (IBAction)editedArtist:(id)sender;
@end
