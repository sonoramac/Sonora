//
//  SNRSongTableCellView.h
//  Sonora
//
//  Created by Indragie Karunaratne on 11-08-04.
//  Copyright 2012 Indragie Karunaratne. All rights reserved.
//

@interface SNRSongTableCellView : NSTableCellView
@property (nonatomic, weak) IBOutlet NSTextField *artistField;
@property (nonatomic, weak) IBOutlet NSTextField *trackNumberField;
@property (nonatomic, weak) IBOutlet NSTextField *durationField;
@property (nonatomic, weak) IBOutlet NSButton *enqueueButton;
@end

@interface SNRSongTableRowView : NSTableRowView
@end