//
//  SNRSearchTableCellView.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-08.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

@class SNRShadowImageView;
@interface SNRSearchTableCellView : NSTableCellView
@property (nonatomic, weak) IBOutlet NSTextField *subtitleTextField;
@property (nonatomic, weak) IBOutlet NSTextField *statisticTextField;
@property (nonatomic, weak) IBOutlet NSImageView *iconImageView;
@property (nonatomic, weak) IBOutlet SNRShadowImageView *artworkImageView;
@property (nonatomic, weak) IBOutlet NSButton *enqueueButton;
@end

@interface SNRSearchTableRowView : NSTableRowView
@end