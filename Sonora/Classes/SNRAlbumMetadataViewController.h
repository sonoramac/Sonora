//
//  SNRAlbumMetadataViewController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 12-02-01.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

#import "SNRMetadataViewController.h"

@class SNRMetadataImageView;
@interface SNRAlbumMetadataViewController : SNRMetadataViewController
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, assign) BOOL compilation;
@property (nonatomic, weak) IBOutlet NSTextField *nameField;
@property (nonatomic, weak) IBOutlet NSTextField *artistField;
@property (nonatomic, weak) IBOutlet SNRMetadataImageView *imageView;
@property (nonatomic, weak) IBOutlet NSButton *compilationCheckbox;
- (IBAction)clickedCompilation:(id)sender;
@end
