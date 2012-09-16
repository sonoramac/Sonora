//
//  SNRAlbumsViewController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-04.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRFileImportOperation.h"
#import "SNRiTunesImportOperation.h"
#import "SNRAlbumGridViewCell.h"
#import "OEGridView.h"

@class SNRSplitView, SNRUIController, SNRAlbumsGridView;
@interface SNRAlbumsViewController : NSViewController <SNRFileImportOperationDelegate, SNRiTunesImportOperationDelegate, OEGridViewDelegate, OEGridViewDataSource, SNRAlbumGridViewCellDelegate>
@property (nonatomic, assign) CGFloat cellWidth;
@property (nonatomic, weak) IBOutlet SNRAlbumsGridView *gridView;
@property (nonatomic, retain) IBOutlet NSScrollView *gridScrollView;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *sortControl;
@property (nonatomic, weak) IBOutlet NSSlider *widthSlider;
- (void)reloadDataWithArtists:(NSArray*)artists;
- (void)reloadDataWithMixes;
- (void)reloadData;

- (IBAction)sortingChanged:(id)sender;
@end
