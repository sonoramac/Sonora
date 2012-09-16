//
//  SNRMetadataViewController.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-12-22.
//  Copyright (c) 2012 Indragie Karunaratne. All rights reserved.
//

@protocol SNRMetadataViewControllerDelegate;
@interface SNRMetadataViewController : NSViewController
@property (nonatomic, assign) id<SNRMetadataViewControllerDelegate> delegate;
@property (nonatomic, retain) NSArray *metadataItems;
@property (nonatomic, retain) NSArray *selectedItems;
- (void)setMetadataItems:(NSArray *)metadataItems selectedIndex:(NSNumber*)index;
- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
@end

@protocol SNRMetadataViewControllerDelegate <NSObject>
@optional
- (void)metadataViewControllerEndedMetadataEditing:(SNRMetadataViewController*)controller;
@end