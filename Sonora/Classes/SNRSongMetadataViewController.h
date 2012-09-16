//
//  SNRSongMetadataViewController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-01-07.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRMetadataViewController.h"

extern NSString* const SNRSongMetadataViewControllerSelectedObjectNotification;
extern NSString* const SNRSongMetadataViewControllerSelectedObjectObjectKey;

@class SNRClickActionTextField;
@interface SNRSongMetadataViewController : SNRMetadataViewController
@property (nonatomic, copy) NSString *name;
@property (nonatomic, retain) NSNumber *trackNumber;
@property (nonatomic, copy) NSString *album;
@property (nonatomic, retain) NSNumber *discNumber;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, retain) NSNumber *playCounts;
@property (nonatomic, copy) NSString *format;
@property (nonatomic, copy) NSString *size;
@property (nonatomic, copy) NSString *bitRate;
@property (nonatomic, copy) NSString *path;
@property (nonatomic, copy) NSAttributedString *lyrics;

@property (nonatomic, weak) IBOutlet NSButton *previousButton;
@property (nonatomic, weak) IBOutlet NSButton *nextButton;
@property (nonatomic, weak) IBOutlet NSTabView *tabView;
@property (nonatomic, weak) IBOutlet SNRClickActionTextField *pathField;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *segmentedControl;
@property (nonatomic, weak) IBOutlet NSTextField *nameField;
@property (nonatomic, weak) IBOutlet NSTextField *trackField;
@property (nonatomic, weak) IBOutlet NSTextField *discField;
@property (nonatomic, weak) IBOutlet NSTextField *albumField;
@property (nonatomic, weak) IBOutlet NSTextField *artistField;
- (IBAction)previous:(id)sender;
- (IBAction)next:(id)sender;
- (IBAction)segmentChanged:(id)sender;
@end
