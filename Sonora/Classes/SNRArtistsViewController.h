//
//  SNRArtistsViewController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-03.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRArtistsStaticNode.h"

@class SNRAlbumsViewController, SNRArtist;
@interface SNRArtistsViewController : NSViewController <NSOutlineViewDataSource, NSOutlineViewDelegate> {
}
@property (nonatomic, weak) IBOutlet NSOutlineView *outlineView;
@property (nonatomic, assign) IBOutlet SNRAlbumsViewController *albumsViewController;
- (BOOL)hasStaticNodeWithType:(SNRArtistsStaticNodeType)type;

- (void)reloadData;
- (void)selectArtist:(id)artist;

- (IBAction)textFieldEndedEditing:(id)sender;
@end
